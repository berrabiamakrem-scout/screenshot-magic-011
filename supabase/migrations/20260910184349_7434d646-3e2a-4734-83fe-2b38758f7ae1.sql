CREATE TYPE public.indicator_type AS ENUM ('quantitative','qualitative');
CREATE TYPE public.indicator_direction AS ENUM ('higher_better','lower_better','maintain_range');
CREATE TYPE public.baseline_status AS ENUM ('adopted','needs_measurement','provisional','unavailable');
CREATE TYPE public.workflow_status AS ENUM ('draft','submitted','approved','returned');
CREATE TYPE public.progress_status AS ENUM ('not_started','preparing','in_progress','advanced','completed');

CREATE OR REPLACE FUNCTION public.progress_percent(_s public.progress_status)
RETURNS int LANGUAGE sql IMMUTABLE SET search_path = public AS $fn$
  SELECT CASE _s
    WHEN 'not_started' THEN 0 WHEN 'preparing' THEN 25 WHEN 'in_progress' THEN 50
    WHEN 'advanced' THEN 75 WHEN 'completed' THEN 100 END;
$fn$;

CREATE TABLE public.indicators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL,
  name_ar text NOT NULL,
  description_ar text,
  phase_objective_id uuid REFERENCES public.phase_objectives(id) ON DELETE CASCADE,
  type public.indicator_type NOT NULL DEFAULT 'quantitative',
  unit_of_measure text,
  direction public.indicator_direction NOT NULL DEFAULT 'higher_better',
  calculation_method text,
  data_source text,
  verification_method text,
  periodicity text,
  responsible_unit_id uuid REFERENCES public.org_units(id) ON DELETE SET NULL,
  version int NOT NULL DEFAULT 1,
  supersedes_id uuid REFERENCES public.indicators(id) ON DELETE SET NULL,
  status public.record_status NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (code, version)
);
CREATE INDEX idx_indicators_po ON public.indicators(phase_objective_id);

CREATE TABLE public.indicator_baselines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  indicator_id uuid NOT NULL REFERENCES public.indicators(id) ON DELETE CASCADE,
  org_unit_id uuid REFERENCES public.org_units(id) ON DELETE CASCADE,
  value numeric,
  value_text text,
  reference_year int,
  reference_date date,
  source text,
  methodology text,
  status public.baseline_status NOT NULL DEFAULT 'needs_measurement',
  validated_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (indicator_id, org_unit_id)
);

CREATE TABLE public.indicator_targets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  indicator_id uuid NOT NULL REFERENCES public.indicators(id) ON DELETE CASCADE,
  scope text NOT NULL CHECK (scope IN ('phase','season')),
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE CASCADE,
  season_id uuid REFERENCES public.seasons(id) ON DELETE CASCADE,
  org_unit_id uuid REFERENCES public.org_units(id) ON DELETE CASCADE,
  target_value numeric,
  target_text text,
  version int NOT NULL DEFAULT 1,
  effective_from date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_targets_indicator ON public.indicator_targets(indicator_id);

CREATE TABLE public.plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  season_id uuid NOT NULL REFERENCES public.seasons(id) ON DELETE RESTRICT,
  title text NOT NULL,
  description text,
  status public.workflow_status NOT NULL DEFAULT 'draft',
  submitted_at timestamptz,
  approved_by uuid,
  approved_at timestamptz,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (org_unit_id, season_id)
);

CREATE TABLE public.activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid REFERENCES public.plans(id) ON DELETE SET NULL,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  season_id uuid NOT NULL REFERENCES public.seasons(id) ON DELETE RESTRICT,
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE SET NULL,
  strategic_objective_id uuid REFERENCES public.strategic_objectives(id) ON DELETE SET NULL,
  phase_objective_id uuid REFERENCES public.phase_objectives(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  start_date date,
  end_date date,
  owner_id uuid,
  expected_beneficiaries int,
  budget numeric,
  workflow_status public.workflow_status NOT NULL DEFAULT 'draft',
  progress_status public.progress_status NOT NULL DEFAULT 'not_started',
  progress_percent int GENERATED ALWAYS AS (
    CASE progress_status WHEN 'not_started' THEN 0 WHEN 'preparing' THEN 25
      WHEN 'in_progress' THEN 50 WHEN 'advanced' THEN 75 WHEN 'completed' THEN 100 END
  ) STORED,
  submitted_at timestamptz,
  approved_by uuid,
  approved_at timestamptz,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_activities_unit_season ON public.activities(org_unit_id, season_id);
CREATE INDEX idx_activities_po ON public.activities(phase_objective_id);

CREATE TABLE public.custom_indicators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  name_ar text NOT NULL,
  description_ar text,
  unit_of_measure text,
  direction public.indicator_direction NOT NULL DEFAULT 'higher_better',
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.activity_indicators (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id uuid NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
  indicator_id uuid REFERENCES public.indicators(id) ON DELETE RESTRICT,
  custom_indicator_id uuid REFERENCES public.custom_indicators(id) ON DELETE RESTRICT,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  weight numeric(6,3) NOT NULL CHECK (weight > 0),
  target_value numeric,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT activity_indicator_target_chk CHECK (
    (indicator_id IS NOT NULL) <> (custom_indicator_id IS NOT NULL))
);
CREATE INDEX idx_activity_indicators_activity ON public.activity_indicators(activity_id);

CREATE TABLE public.indicator_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  indicator_id uuid REFERENCES public.indicators(id) ON DELETE CASCADE,
  custom_indicator_id uuid REFERENCES public.custom_indicators(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  season_id uuid REFERENCES public.seasons(id) ON DELETE SET NULL,
  activity_id uuid REFERENCES public.activities(id) ON DELETE CASCADE,
  actual_value numeric,
  qualitative_note text,
  reported_by uuid DEFAULT auth.uid(),
  reported_at timestamptz NOT NULL DEFAULT now(),
  status public.workflow_status NOT NULL DEFAULT 'submitted',
  reviewer_id uuid,
  review_note text,
  verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT indicator_result_target_chk CHECK (
    (indicator_id IS NOT NULL) <> (custom_indicator_id IS NOT NULL))
);
CREATE INDEX idx_results_unit_season ON public.indicator_results(org_unit_id, season_id);

CREATE TABLE public.evidence_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  filename text,
  uploaded_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_evidence_entity ON public.evidence_files(entity_type, entity_id);

CREATE TABLE public.activity_progress_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id uuid NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  from_status public.progress_status,
  to_status public.progress_status NOT NULL,
  percent int NOT NULL,
  note text NOT NULL,
  evidence_file_id uuid REFERENCES public.evidence_files(id) ON DELETE SET NULL,
  changed_by uuid DEFAULT auth.uid(),
  changed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_progress_activity ON public.activity_progress_history(activity_id, changed_at);

CREATE TABLE public.approval_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  requested_by uuid NOT NULL DEFAULT auth.uid(),
  requester_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  approver_role public.app_role,
  approver_unit_id uuid REFERENCES public.org_units(id) ON DELETE SET NULL,
  status public.workflow_status NOT NULL DEFAULT 'submitted',
  reason text,
  note text,
  decision_by uuid,
  decision_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_approvals_entity ON public.approval_requests(entity_type, entity_id);
CREATE INDEX idx_approvals_status ON public.approval_requests(status);

CREATE OR REPLACE FUNCTION public.validate_activity_submission()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $fn$
DECLARE total numeric;
BEGIN
  IF NEW.workflow_status = 'submitted' AND (TG_OP = 'INSERT' OR OLD.workflow_status IS DISTINCT FROM 'submitted') THEN
    SELECT COALESCE(sum(weight), 0) INTO total FROM public.activity_indicators WHERE activity_id = NEW.id;
    IF total <> 100 THEN
      RAISE EXCEPTION 'مجموع أوزان مؤشرات النشاط يجب أن يساوي 100%% بالضبط (الحالي: %)', total;
    END IF;
    NEW.submitted_at := COALESCE(NEW.submitted_at, now());
  END IF;
  RETURN NEW;
END;
$fn$;

CREATE TRIGGER trg_activity_submission BEFORE INSERT OR UPDATE ON public.activities
FOR EACH ROW EXECUTE FUNCTION public.validate_activity_submission();

CREATE OR REPLACE FUNCTION public.log_activity_progress()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $fn$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.progress_status IS DISTINCT FROM OLD.progress_status THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.activity_progress_history h
      WHERE h.activity_id = NEW.id AND h.to_status = NEW.progress_status
        AND h.changed_at > now() - interval '5 seconds')
    THEN
      RAISE EXCEPTION 'تغيير حالة التقدم يتطلب تسجيل ملاحظة إلزامية في سجل التقدم';
    END IF;
  END IF;
  RETURN NEW;
END;
$fn$;

CREATE TRIGGER trg_activity_progress AFTER UPDATE ON public.activities
FOR EACH ROW EXECUTE FUNCTION public.log_activity_progress();

CREATE TRIGGER trg_indicators_updated BEFORE UPDATE ON public.indicators FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_baselines_updated BEFORE UPDATE ON public.indicator_baselines FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_targets_updated BEFORE UPDATE ON public.indicator_targets FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_plans_updated BEFORE UPDATE ON public.plans FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_activities_updated BEFORE UPDATE ON public.activities FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_custom_ind_updated BEFORE UPDATE ON public.custom_indicators FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_results_updated BEFORE UPDATE ON public.indicator_results FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_approvals_updated BEFORE UPDATE ON public.approval_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE, DELETE ON public.indicators, public.indicator_baselines, public.indicator_targets,
  public.plans, public.activities, public.custom_indicators, public.activity_indicators,
  public.indicator_results, public.evidence_files, public.activity_progress_history,
  public.approval_requests TO authenticated;
GRANT ALL ON public.indicators, public.indicator_baselines, public.indicator_targets,
  public.plans, public.activities, public.custom_indicators, public.activity_indicators,
  public.indicator_results, public.evidence_files, public.activity_progress_history,
  public.approval_requests TO service_role;

ALTER TABLE public.indicators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.indicator_baselines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.indicator_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_indicators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_indicators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.indicator_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_progress_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY indicators_read ON public.indicators FOR SELECT TO authenticated USING (true);
CREATE POLICY indicators_write ON public.indicators FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY baselines_read ON public.indicator_baselines FOR SELECT TO authenticated USING (true);
CREATE POLICY baselines_write ON public.indicator_baselines FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY targets_read ON public.indicator_targets FOR SELECT TO authenticated USING (true);
CREATE POLICY targets_write ON public.indicator_targets FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());

CREATE POLICY plans_read ON public.plans FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY plans_write ON public.plans FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY activities_read ON public.activities FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY activities_write ON public.activities FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY custom_ind_read ON public.custom_indicators FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY custom_ind_write ON public.custom_indicators FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY act_ind_read ON public.activity_indicators FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY act_ind_write ON public.activity_indicators FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY results_read ON public.indicator_results FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY results_write ON public.indicator_results FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY evidence_files_read ON public.evidence_files FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY evidence_files_write ON public.evidence_files FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY progress_read ON public.activity_progress_history FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY progress_insert ON public.activity_progress_history FOR INSERT TO authenticated WITH CHECK (public.can_manage_unit(org_unit_id));

CREATE POLICY approvals_read ON public.approval_requests FOR SELECT TO authenticated
  USING (requested_by = auth.uid() OR public.can_access_unit(requester_unit_id));
CREATE POLICY approvals_insert ON public.approval_requests FOR INSERT TO authenticated
  WITH CHECK (public.can_manage_unit(requester_unit_id));
CREATE POLICY approvals_update ON public.approval_requests FOR UPDATE TO authenticated
  USING (public.can_manage_unit(requester_unit_id) OR public.can_access_unit(requester_unit_id))
  WITH CHECK (public.can_manage_unit(requester_unit_id) OR public.can_access_unit(requester_unit_id));