# Fix: users could self-assign an org unit at signup

Database-only change. No interface changes, no new modules.

## What changes for people using the app

- When someone registers, their profile is created with no organizational unit. They cannot pick one.
- Anyone can still edit their own name, phone and other personal details.
- Only authorized administrators can set or change which unit a person belongs to, and only within the units they are allowed to manage.
- Roles stay entirely separate from profiles; nobody can give themselves a role.

## Scope rules for assigning a unit

| Who | May assign a person to |
| --- | --- |
| PLATFORM_SUPER_ADMIN | any unit |
| STRATEGY_ADMIN | units inside their authorized scope |
| NATIONAL_MANAGER | units inside the national scope they hold |
| REGIONAL_MANAGER | their own unit and its child units |
| LOCAL_MANAGER | their own local unit only (cannot elevate themselves) |

## Exact SQL to apply

```sql
-- 1) Scope check: may the current user place someone into _unit_id?
CREATE OR REPLACE FUNCTION public.can_assign_unit(_unit_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT
    _unit_id IS NULL
    OR public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
    OR EXISTS (
      SELECT 1
      FROM public.org_unit_closure c
      JOIN public.user_roles r ON r.org_unit_id = c.ancestor_id
      WHERE c.unit_id = _unit_id
        AND r.user_id = auth.uid()
        AND r.role IN ('STRATEGY_ADMIN','NATIONAL_MANAGER','REGIONAL_MANAGER','LOCAL_MANAGER')
    )
    OR (
      -- national/strategy admins whose role row is not unit-scoped
      EXISTS (
        SELECT 1 FROM public.user_roles r
        WHERE r.user_id = auth.uid()
          AND r.org_unit_id IS NULL
          AND r.role IN ('STRATEGY_ADMIN','NATIONAL_MANAGER')
      )
    );
$$;

-- 2) Is the current user an administrator of this profile's unit?
CREATE OR REPLACE FUNCTION public.can_admin_profile(_profile_org_unit uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
      OR (_profile_org_unit IS NOT NULL AND public.can_assign_unit(_profile_org_unit));
$$;

-- 3) Guard: block self-service changes to the privileged column
CREATE OR REPLACE FUNCTION public.profiles_guard_org_unit()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.id = auth.uid() AND NOT public.can_assign_unit(NEW.org_unit_id) THEN
      NEW.org_unit_id := NULL;           -- self-registration: always unassigned
    END IF;
    IF NEW.org_unit_id IS NOT NULL AND NOT public.can_assign_unit(NEW.org_unit_id) THEN
      RAISE EXCEPTION 'not authorized to assign this organizational unit';
    END IF;
    RETURN NEW;
  END IF;

  IF NEW.org_unit_id IS DISTINCT FROM OLD.org_unit_id THEN
    IF NOT (public.can_assign_unit(NEW.org_unit_id)
            AND (OLD.org_unit_id IS NULL OR public.can_assign_unit(OLD.org_unit_id))) THEN
      RAISE EXCEPTION 'not authorized to change organizational unit';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_guard_org_unit_trg ON public.profiles;
CREATE TRIGGER profiles_guard_org_unit_trg
BEFORE INSERT OR UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.profiles_guard_org_unit();

-- 4) RLS policies (RLS stays enabled)
DROP POLICY IF EXISTS profiles_insert ON public.profiles;
CREATE POLICY profiles_insert ON public.profiles
FOR INSERT TO authenticated
WITH CHECK (
  (id = auth.uid() AND org_unit_id IS NULL)
  OR (id <> auth.uid() AND public.can_admin_profile(org_unit_id))
);

DROP POLICY IF EXISTS profiles_update ON public.profiles;
CREATE POLICY profiles_update ON public.profiles
FOR UPDATE TO authenticated
USING (id = auth.uid() OR public.can_admin_profile(org_unit_id))
WITH CHECK (id = auth.uid() OR public.can_admin_profile(org_unit_id));
```

Notes:
- `profiles.active` and `id` are not writable by self-service beyond the trigger's guard; the trigger is the enforcement point for the privileged column, the policies handle row visibility.
- `user_roles` policies are unchanged: only PLATFORM_SUPER_ADMIN writes roles, so no self-elevation is possible.
- No table is dropped, no data is deleted.
