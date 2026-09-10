CREATE TYPE public.record_status AS ENUM ('draft','active','archived');
CREATE TYPE public.validation_status AS ENUM ('draft','submitted','validated','rejected');

CREATE TABLE public.strategies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  title_ar text NOT NULL,
  start_year int NOT NULL,
  end_year int NOT NULL,
  version int NOT NULL DEFAULT 1,
  status public.record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.strategy_phases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  strategy_id uuid NOT NULL REFERENCES public.strategies(id) ON DELETE CASCADE,
  number int NOT NULL,
  label text NOT NULL,
  start_year int NOT NULL,
  end_year int NOT NULL,
  status public.record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (strategy_id, number)
);

CREATE TABLE public.seasons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phase_id uuid NOT NULL REFERENCES public.strategy_phases(id) ON DELETE CASCADE,
  label text NOT NULL UNIQUE,
  start_date date NOT NULL,
  end_date date NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_seasons_phase ON public.seasons(phase_id);

CREATE TABLE public.strategic_paths (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  strategy_id uuid NOT NULL REFERENCES public.strategies(id) ON DELETE CASCADE,
  number int NOT NULL,
  code text,
  title_ar text NOT NULL,
  description_ar text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (strategy_id, number)
);

CREATE TABLE public.priorities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  path_id uuid NOT NULL REFERENCES public.strategic_paths(id) ON DELETE CASCADE,
  number int NOT NULL,
  code text,
  title_ar text NOT NULL,
  description_ar text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (path_id, number)
);
CREATE INDEX idx_priorities_path ON public.priorities(path_id);

CREATE TABLE public.strategic_objectives (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  priority_id uuid NOT NULL REFERENCES public.priorities(id) ON DELETE CASCADE,
  code text NOT NULL,
  title_ar text NOT NULL,
  description_ar text,
  status public.record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (priority_id, code)
);
CREATE INDEX idx_strategic_objectives_priority ON public.strategic_objectives(priority_id);

CREATE TABLE public.phase_objectives (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  strategic_objective_id uuid NOT NULL REFERENCES public.strategic_objectives(id) ON DELETE CASCADE,
  phase_id uuid NOT NULL REFERENCES public.strategy_phases(id) ON DELETE CASCADE,
  code text NOT NULL,
  title_ar text NOT NULL,
  description_ar text,
  version int NOT NULL DEFAULT 1,
  supersedes_id uuid REFERENCES public.phase_objectives(id) ON DELETE SET NULL,
  status public.record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (strategic_objective_id, phase_id, code, version)
);
CREATE INDEX idx_phase_objectives_so ON public.phase_objectives(strategic_objective_id);
CREATE INDEX idx_phase_objectives_phase ON public.phase_objectives(phase_id);

CREATE TABLE public.data_catalog (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name_ar text NOT NULL,
  category text NOT NULL,
  unit_of_measure text,
  description_ar text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_data_catalog_category ON public.data_catalog(category);

CREATE TABLE public.reference_data (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  catalog_id uuid NOT NULL REFERENCES public.data_catalog(id) ON DELETE RESTRICT,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  season_id uuid REFERENCES public.seasons(id) ON DELETE SET NULL,
  year int,
  value_numeric numeric,
  value_text text,
  breakdown jsonb NOT NULL DEFAULT '{}'::jsonb,
  unit_of_measure text,
  source text,
  data_owner text,
  status public.validation_status NOT NULL DEFAULT 'draft',
  validated_by uuid,
  validated_at timestamptz,
  notes text,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reference_data_period_chk CHECK (season_id IS NOT NULL OR year IS NOT NULL)
);
CREATE INDEX idx_reference_data_unit_season ON public.reference_data(org_unit_id, season_id);
CREATE INDEX idx_reference_data_catalog ON public.reference_data(catalog_id);
CREATE UNIQUE INDEX uq_reference_data_point
  ON public.reference_data(catalog_id, org_unit_id, COALESCE(season_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(year, -1), breakdown);

CREATE TRIGGER trg_strategies_updated BEFORE UPDATE ON public.strategies FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_strategy_phases_updated BEFORE UPDATE ON public.strategy_phases FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_seasons_updated BEFORE UPDATE ON public.seasons FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_paths_updated BEFORE UPDATE ON public.strategic_paths FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_priorities_updated BEFORE UPDATE ON public.priorities FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_so_updated BEFORE UPDATE ON public.strategic_objectives FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_po_updated BEFORE UPDATE ON public.phase_objectives FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_catalog_updated BEFORE UPDATE ON public.data_catalog FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_refdata_updated BEFORE UPDATE ON public.reference_data FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE, DELETE ON public.strategies TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.strategy_phases TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.seasons TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.strategic_paths TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.priorities TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.strategic_objectives TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.phase_objectives TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.data_catalog TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reference_data TO authenticated;
GRANT ALL ON public.strategies, public.strategy_phases, public.seasons, public.strategic_paths,
  public.priorities, public.strategic_objectives, public.phase_objectives,
  public.data_catalog, public.reference_data TO service_role;

ALTER TABLE public.strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategy_phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seasons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.priorities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phase_objectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reference_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY strategies_read ON public.strategies FOR SELECT TO authenticated USING (true);
CREATE POLICY strategies_write ON public.strategies FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY phases_read ON public.strategy_phases FOR SELECT TO authenticated USING (true);
CREATE POLICY phases_write ON public.strategy_phases FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY seasons_read ON public.seasons FOR SELECT TO authenticated USING (true);
CREATE POLICY seasons_write ON public.seasons FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY paths_read ON public.strategic_paths FOR SELECT TO authenticated USING (true);
CREATE POLICY paths_write ON public.strategic_paths FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY priorities_read ON public.priorities FOR SELECT TO authenticated USING (true);
CREATE POLICY priorities_write ON public.priorities FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY so_read ON public.strategic_objectives FOR SELECT TO authenticated USING (true);
CREATE POLICY so_write ON public.strategic_objectives FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY po_read ON public.phase_objectives FOR SELECT TO authenticated USING (true);
CREATE POLICY po_write ON public.phase_objectives FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY catalog_read ON public.data_catalog FOR SELECT TO authenticated USING (true);
CREATE POLICY catalog_write ON public.data_catalog FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());

CREATE POLICY refdata_read ON public.reference_data FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY refdata_insert ON public.reference_data FOR INSERT TO authenticated WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY refdata_update ON public.reference_data FOR UPDATE TO authenticated
  USING (public.can_manage_unit(org_unit_id) OR public.is_strategy_admin())
  WITH CHECK (public.can_manage_unit(org_unit_id) OR public.is_strategy_admin());
CREATE POLICY refdata_delete ON public.reference_data FOR DELETE TO authenticated USING (public.can_manage_unit(org_unit_id));