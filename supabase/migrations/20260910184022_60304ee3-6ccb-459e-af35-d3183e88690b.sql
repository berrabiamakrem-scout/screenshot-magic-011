CREATE TYPE public.org_level AS ENUM ('national','regional','local');
CREATE TYPE public.app_role AS ENUM (
  'PLATFORM_SUPER_ADMIN','STRATEGY_ADMIN','NATIONAL_MANAGER','REGIONAL_MANAGER',
  'LOCAL_MANAGER','ACTIVITY_OWNER','REVIEWER','EVALUATOR','VIEWER'
);

CREATE TABLE public.org_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar text NOT NULL,
  name_fr text,
  code text UNIQUE,
  level public.org_level NOT NULL,
  parent_id uuid REFERENCES public.org_units(id) ON DELETE RESTRICT,
  region_code text,
  governorate text,
  latitude numeric,
  longitude numeric,
  active boolean NOT NULL DEFAULT true,
  archived_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_org_units_parent ON public.org_units(parent_id);
CREATE INDEX idx_org_units_level ON public.org_units(level);

CREATE TABLE public.org_unit_closure (
  unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  ancestor_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  depth int NOT NULL,
  PRIMARY KEY (unit_id, ancestor_id)
);
CREATE INDEX idx_closure_ancestor ON public.org_unit_closure(ancestor_id);

CREATE OR REPLACE FUNCTION public.rebuild_org_unit_closure()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
BEGIN
  DELETE FROM public.org_unit_closure WHERE true;
  INSERT INTO public.org_unit_closure (unit_id, ancestor_id, depth)
  WITH RECURSIVE tree AS (
    SELECT id AS unit_id, id AS ancestor_id, 0 AS depth FROM public.org_units
    UNION ALL
    SELECT t.unit_id, u.parent_id, t.depth + 1
    FROM tree t JOIN public.org_units u ON u.id = t.ancestor_id
    WHERE u.parent_id IS NOT NULL
  )
  SELECT unit_id, ancestor_id, depth FROM tree;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.org_units_closure_trigger()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
BEGIN
  PERFORM public.rebuild_org_unit_closure();
  RETURN NULL;
END;
$fn$;

CREATE TRIGGER trg_org_units_closure
AFTER INSERT OR UPDATE OF parent_id OR DELETE ON public.org_units
FOR EACH STATEMENT EXECUTE FUNCTION public.org_units_closure_trigger();

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  full_name text,
  phone text,
  org_unit_id uuid REFERENCES public.org_units(id) ON DELETE SET NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_profiles_unit ON public.profiles(org_unit_id);

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  role public.app_role NOT NULL,
  org_unit_id uuid REFERENCES public.org_units(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role, org_unit_id)
);
CREATE INDEX idx_user_roles_user ON public.user_roles(user_id);
CREATE INDEX idx_user_roles_unit ON public.user_roles(org_unit_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role);
$fn$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN');
$fn$;

CREATE OR REPLACE FUNCTION public.is_strategy_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
      OR public.has_role(auth.uid(), 'STRATEGY_ADMIN');
$fn$;

CREATE OR REPLACE FUNCTION public.can_access_unit(_unit_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT _unit_id IS NULL
    OR public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
    OR public.has_role(auth.uid(), 'STRATEGY_ADMIN')
    OR public.has_role(auth.uid(), 'NATIONAL_MANAGER')
    OR public.has_role(auth.uid(), 'REVIEWER')
    OR public.has_role(auth.uid(), 'EVALUATOR')
    OR EXISTS (
      SELECT 1 FROM public.org_unit_closure c
      JOIN public.user_roles r ON r.org_unit_id = c.ancestor_id
      WHERE c.unit_id = _unit_id AND r.user_id = auth.uid()
    );
$fn$;

CREATE OR REPLACE FUNCTION public.can_manage_unit(_unit_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $fn$
  SELECT public.has_role(auth.uid(), 'PLATFORM_SUPER_ADMIN')
    OR public.has_role(auth.uid(), 'NATIONAL_MANAGER')
    OR (_unit_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM public.org_unit_closure c
      JOIN public.user_roles r ON r.org_unit_id = c.ancestor_id
      WHERE c.unit_id = _unit_id
        AND r.user_id = auth.uid()
        AND r.role IN ('STRATEGY_ADMIN','REGIONAL_MANAGER','LOCAL_MANAGER','ACTIVITY_OWNER')
    ));
$fn$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $fn$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$fn$;

CREATE TRIGGER trg_org_units_updated BEFORE UPDATE ON public.org_units
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE, DELETE ON public.org_units TO authenticated;
GRANT ALL ON public.org_units TO service_role;
GRANT SELECT ON public.org_unit_closure TO authenticated;
GRANT ALL ON public.org_unit_closure TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;

ALTER TABLE public.org_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_unit_closure ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY org_units_read ON public.org_units FOR SELECT TO authenticated USING (true);
CREATE POLICY org_units_write ON public.org_units FOR ALL TO authenticated
  USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());

CREATE POLICY closure_read ON public.org_unit_closure FOR SELECT TO authenticated USING (true);

CREATE POLICY profiles_read ON public.profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR public.can_access_unit(org_unit_id));
CREATE POLICY profiles_insert ON public.profiles FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid() OR public.is_super_admin());
CREATE POLICY profiles_update ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid() OR public.can_manage_unit(org_unit_id))
  WITH CHECK (id = auth.uid() OR public.can_manage_unit(org_unit_id));
CREATE POLICY profiles_delete ON public.profiles FOR DELETE TO authenticated
  USING (public.is_super_admin());

CREATE POLICY user_roles_read ON public.user_roles FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR public.is_super_admin());
CREATE POLICY user_roles_write ON public.user_roles FOR ALL TO authenticated
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());