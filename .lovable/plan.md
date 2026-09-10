# Fix: users could self-assign an org unit at signup (revised)

Database-only change. No interface changes, no new modules, no strategic data touched.

## Behaviour after the change

- Self-registration is accepted only when the row is the person's own and has no organizational unit. Any other attempt is rejected with an authorization error — nothing is silently corrected.
- Nobody can change their own organizational unit through profile editing, whatever role they hold. Another authorized administrator must do it.
- Self-editing is limited to ordinary personal details (name, phone, and any future non-privileged field). Identity, unit, active flag and creation time cannot be touched by the person themselves.
- Administrators can set a person's unit only inside the scope they are authorized for.
- Role management is untouched: nobody can give themselves a role.
- Every unit/active change goes through one guard function, so audit logging can be added later without redesign.

Note: the profile table currently holds name, phone, unit, active status and timestamps — there is no avatar field yet. The guard protects the privileged columns by name, so a future avatar field is editable by default and any new privileged field is added to the guard list.

## Scope rules for assigning a unit

| Who | May assign into |
| --- | --- |
| PLATFORM_SUPER_ADMIN | any unit (system-wide, explicit) |
| STRATEGY_ADMIN | units under the unit their role row names; a role row with no unit is treated as national-wide only because it is explicitly declared so below |
| NATIONAL_MANAGER | same rule as above, explicitly national-wide |
| REGIONAL_MANAGER | own regional unit and its descendants only — never inferred from a null-scoped role row |
| LOCAL_MANAGER | own local unit only |

A null unit on a role row grants nothing by itself; it counts only for the two roles listed as national-wide.

## Exact SQL to apply

```sql
-- 1) Which roles are national-wide when their role row has no unit
CREATE OR REPLACE FUNCTION public.is_national_scope()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles r
    WHERE r.user_id = auth.uid()
      AND r.org_unit_id IS NULL
      AND r.role IN ('STRATEGY_ADMIN','NATIONAL_MANAGER')
  );
$$;

-- 2) May the current user place someone into _unit_id?
CREATE OR REPLACE FUNCTION public.can_assign_unit(_unit_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT _unit_id IS NOT NULL AND (
    public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
    OR public.is_national_scope()
    OR EXISTS (
      SELECT 1
      FROM public.org_unit_closure c
      JOIN public.user_roles r ON r.org_unit_id = c.ancestor_id
      WHERE c.unit_id = _unit_id
        AND r.user_id = auth.uid()
        AND r.role IN ('STRATEGY_ADMIN','NATIONAL_MANAGER','REGIONAL_MANAGER','LOCAL_MANAGER')
    )
  );
$$;

-- 3) May the current user administer a profile currently in _profile_org_unit?
CREATE OR REPLACE FUNCTION public.can_admin_profile(_profile_org_unit uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
      OR public.is_national_scope()
      OR public.can_assign_unit(_profile_org_unit);
$$;

-- 4) Column-level guard: RLS controls rows, this controls privileged columns
CREATE OR REPLACE FUNCTION public.profiles_guard()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  self boolean := (auth.uid() IS NOT NULL AND COALESCE(NEW.id, OLD.id) = auth.uid());
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF self THEN
      IF NEW.org_unit_id IS NOT NULL THEN
        RAISE EXCEPTION 'not authorized: self-registration cannot set an organizational unit'
          USING ERRCODE = '42501';
      END IF;
      NEW.active := true;
    ELSE
      IF NOT public.can_assign_unit(NEW.org_unit_id) THEN
        RAISE EXCEPTION 'not authorized to assign this organizational unit'
          USING ERRCODE = '42501';
      END IF;
    END IF;
    RETURN NEW;
  END IF;

  -- UPDATE
  IF NEW.id IS DISTINCT FROM OLD.id OR NEW.created_at IS DISTINCT FROM OLD.created_at THEN
    RAISE EXCEPTION 'not authorized to change identity or creation time'
      USING ERRCODE = '42501';
  END IF;

  IF self THEN
    IF NEW.org_unit_id IS DISTINCT FROM OLD.org_unit_id THEN
      RAISE EXCEPTION 'not authorized: organizational unit must be changed by an administrator'
        USING ERRCODE = '42501';
    END IF;
    IF NEW.active IS DISTINCT FROM OLD.active THEN
      RAISE EXCEPTION 'not authorized to change your own active status'
        USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
  END IF;

  IF NEW.org_unit_id IS DISTINCT FROM OLD.org_unit_id THEN
    IF NOT public.can_assign_unit(NEW.org_unit_id) THEN
      RAISE EXCEPTION 'not authorized to assign this organizational unit'
        USING ERRCODE = '42501';
    END IF;
    IF OLD.org_unit_id IS NOT NULL AND NOT public.can_assign_unit(OLD.org_unit_id) THEN
      RAISE EXCEPTION 'not authorized to move a user out of their current unit'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  IF NEW.active IS DISTINCT FROM OLD.active AND NOT public.can_admin_profile(OLD.org_unit_id) THEN
    RAISE EXCEPTION 'not authorized to change active status' USING ERRCODE = '42501';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_guard_trg ON public.profiles;
CREATE TRIGGER profiles_guard_trg
BEFORE INSERT OR UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.profiles_guard();

-- 5) RLS policies (RLS stays enabled; user_roles policies untouched)
DROP POLICY IF EXISTS profiles_insert ON public.profiles;
CREATE POLICY profiles_insert ON public.profiles
FOR INSERT TO authenticated
WITH CHECK (
  (id = auth.uid() AND org_unit_id IS NULL)
  OR (id <> auth.uid() AND public.can_assign_unit(org_unit_id))
);

DROP POLICY IF EXISTS profiles_update ON public.profiles;
CREATE POLICY profiles_update ON public.profiles
FOR UPDATE TO authenticated
USING (id = auth.uid() OR public.can_admin_profile(org_unit_id))
WITH CHECK (id = auth.uid() OR public.can_admin_profile(org_unit_id));

-- 6) Function privileges
REVOKE ALL ON FUNCTION public.is_national_scope() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.can_assign_unit(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_admin_profile(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.profiles_guard() FROM PUBLIC, anon, authenticated;

-- policies evaluate these two as the calling role, so they need EXECUTE
GRANT EXECUTE ON FUNCTION public.can_assign_unit(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_admin_profile(uuid) TO authenticated;
```

Nothing is dropped or deleted; existing profile rows are unaffected.
