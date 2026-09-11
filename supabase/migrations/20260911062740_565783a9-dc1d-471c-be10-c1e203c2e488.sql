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

CREATE OR REPLACE FUNCTION public.can_admin_profile(_profile_org_unit uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
      OR public.is_national_scope()
      OR public.can_assign_unit(_profile_org_unit);
$$;

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

REVOKE ALL ON FUNCTION public.is_national_scope() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.can_assign_unit(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_admin_profile(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.profiles_guard() FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.can_assign_unit(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_admin_profile(uuid) TO authenticated;