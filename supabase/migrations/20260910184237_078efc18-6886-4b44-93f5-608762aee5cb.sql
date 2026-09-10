CREATE TYPE public.diagnosis_type AS ENUM ('swot','pestel');
CREATE TYPE public.swot_type AS ENUM ('strength','weakness','opportunity','threat');
CREATE TYPE public.pestel_dimension AS ENUM ('political','economic','social','technological','environmental','legal');
CREATE TYPE public.weight_set_status AS ENUM ('draft','approved','active','archived');

CREATE TABLE public.diagnoses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE SET NULL,
  season_id uuid REFERENCES public.seasons(id) ON DELETE SET NULL,
  type public.diagnosis_type NOT NULL,
  title text,
  status public.validation_status NOT NULL DEFAULT 'draft',
  created_by uuid DEFAULT auth.uid(),
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_diagnoses_unit ON public.diagnoses(org_unit_id);

CREATE TABLE public.swot_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  diagnosis_id uuid NOT NULL REFERENCES public.diagnoses(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE SET NULL,
  type public.swot_type NOT NULL,
  analysis_area text NOT NULL,
  description text NOT NULL,
  presence_score int NOT NULL CHECK (presence_score BETWEEN 1 AND 10),
  impact_score int NOT NULL CHECK (impact_score BETWEEN 1 AND 10),
  result int GENERATED ALWAYS AS (presence_score * impact_score) STORED,
  notes text,
  status public.validation_status NOT NULL DEFAULT 'draft',
  created_by uuid DEFAULT auth.uid(),
  approved_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_swot_diagnosis ON public.swot_items(diagnosis_id);
CREATE INDEX idx_swot_unit ON public.swot_items(org_unit_id);

CREATE TABLE public.pestel_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  diagnosis_id uuid NOT NULL REFERENCES public.diagnoses(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  dimension public.pestel_dimension NOT NULL,
  description text NOT NULL,
  influence text,
  probability_score int CHECK (probability_score BETWEEN 1 AND 10),
  impact_score int CHECK (impact_score BETWEEN 1 AND 10),
  affected_areas text[],
  source text,
  status public.validation_status NOT NULL DEFAULT 'draft',
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_pestel_diagnosis ON public.pestel_items(diagnosis_id);

CREATE TABLE public.pestel_swot_links (
  pestel_item_id uuid NOT NULL REFERENCES public.pestel_items(id) ON DELETE CASCADE,
  swot_item_id uuid NOT NULL REFERENCES public.swot_items(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (pestel_item_id, swot_item_id)
);

CREATE TABLE public.diagnosis_evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  swot_item_id uuid REFERENCES public.swot_items(id) ON DELETE CASCADE,
  pestel_item_id uuid REFERENCES public.pestel_items(id) ON DELETE CASCADE,
  reference_data_id uuid REFERENCES public.reference_data(id) ON DELETE SET NULL,
  file_path text,
  note text,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT diagnosis_evidence_target_chk CHECK (swot_item_id IS NOT NULL OR pestel_item_id IS NOT NULL)
);

CREATE TABLE public.strategic_issues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  rank int,
  status public.validation_status NOT NULL DEFAULT 'draft',
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.strategic_issue_sources (
  issue_id uuid NOT NULL REFERENCES public.strategic_issues(id) ON DELETE CASCADE,
  swot_item_id uuid REFERENCES public.swot_items(id) ON DELETE CASCADE,
  pestel_item_id uuid REFERENCES public.pestel_items(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  id uuid PRIMARY KEY DEFAULT gen_random_uuid()
);

CREATE TABLE public.strategic_issue_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  issue_id uuid NOT NULL REFERENCES public.strategic_issues(id) ON DELETE CASCADE,
  priority_id uuid REFERENCES public.priorities(id) ON DELETE CASCADE,
  strategic_objective_id uuid REFERENCES public.strategic_objectives(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE
);

CREATE TABLE public.weight_sets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  strategy_id uuid NOT NULL REFERENCES public.strategies(id) ON DELETE CASCADE,
  phase_id uuid REFERENCES public.strategy_phases(id) ON DELETE CASCADE,
  version int NOT NULL DEFAULT 1,
  status public.weight_set_status NOT NULL DEFAULT 'draft',
  effective_from date,
  change_reason text,
  approved_by uuid,
  approved_at timestamptz,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (strategy_id, phase_id, version)
);

CREATE TABLE public.priority_weights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  weight_set_id uuid NOT NULL REFERENCES public.weight_sets(id) ON DELETE CASCADE,
  priority_id uuid NOT NULL REFERENCES public.priorities(id) ON DELETE CASCADE,
  weight numeric(6,3) NOT NULL CHECK (weight >= 0),
  UNIQUE (weight_set_id, priority_id)
);

CREATE TABLE public.strategic_objective_weights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  weight_set_id uuid NOT NULL REFERENCES public.weight_sets(id) ON DELETE CASCADE,
  strategic_objective_id uuid NOT NULL REFERENCES public.strategic_objectives(id) ON DELETE CASCADE,
  weight numeric(6,3) NOT NULL CHECK (weight >= 0),
  UNIQUE (weight_set_id, strategic_objective_id)
);

CREATE TABLE public.phase_objective_weights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  weight_set_id uuid NOT NULL REFERENCES public.weight_sets(id) ON DELETE CASCADE,
  phase_objective_id uuid NOT NULL REFERENCES public.phase_objectives(id) ON DELETE CASCADE,
  weight numeric(6,3) NOT NULL CHECK (weight >= 0),
  UNIQUE (weight_set_id, phase_objective_id)
);

CREATE OR REPLACE FUNCTION public.validate_weight_set_activation()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $fn$
DECLARE bad_count int;
BEGIN
  IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM 'active') THEN
    SELECT count(*) INTO bad_count
    FROM public.strategic_objective_weights sow
    LEFT JOIN (
      SELECT po.strategic_objective_id, sum(pow.weight) AS total
      FROM public.phase_objective_weights pow
      JOIN public.phase_objectives po ON po.id = pow.phase_objective_id
      WHERE pow.weight_set_id = NEW.id
      GROUP BY po.strategic_objective_id
    ) agg ON agg.strategic_objective_id = sow.strategic_objective_id
    WHERE sow.weight_set_id = NEW.id
      AND COALESCE(agg.total, 0) <> sow.weight;
    IF bad_count > 0 THEN
      RAISE EXCEPTION 'لا يمكن تفعيل مجموعة الأوزان: أوزان أهداف المرحلة لا تساوي وزن الهدف الاستراتيجي في % حالة', bad_count;
    END IF;
  END IF;
  RETURN NEW;
END;
$fn$;

CREATE TRIGGER trg_weight_set_activation BEFORE INSERT OR UPDATE ON public.weight_sets
FOR EACH ROW EXECUTE FUNCTION public.validate_weight_set_activation();

CREATE TRIGGER trg_diagnoses_updated BEFORE UPDATE ON public.diagnoses FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_swot_updated BEFORE UPDATE ON public.swot_items FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_pestel_updated BEFORE UPDATE ON public.pestel_items FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_issues_updated BEFORE UPDATE ON public.strategic_issues FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_weight_sets_updated BEFORE UPDATE ON public.weight_sets FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE, DELETE ON public.diagnoses, public.swot_items, public.pestel_items,
  public.pestel_swot_links, public.diagnosis_evidence, public.strategic_issues,
  public.strategic_issue_sources, public.strategic_issue_links,
  public.weight_sets, public.priority_weights, public.strategic_objective_weights,
  public.phase_objective_weights TO authenticated;
GRANT ALL ON public.diagnoses, public.swot_items, public.pestel_items,
  public.pestel_swot_links, public.diagnosis_evidence, public.strategic_issues,
  public.strategic_issue_sources, public.strategic_issue_links,
  public.weight_sets, public.priority_weights, public.strategic_objective_weights,
  public.phase_objective_weights TO service_role;

ALTER TABLE public.diagnoses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swot_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pestel_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pestel_swot_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diagnosis_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_issue_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_issue_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.priority_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategic_objective_weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phase_objective_weights ENABLE ROW LEVEL SECURITY;

CREATE POLICY diagnoses_read ON public.diagnoses FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY diagnoses_write ON public.diagnoses FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY swot_read ON public.swot_items FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY swot_write ON public.swot_items FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY pestel_read ON public.pestel_items FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY pestel_write ON public.pestel_items FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY pslinks_read ON public.pestel_swot_links FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY pslinks_write ON public.pestel_swot_links FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY evidence_read ON public.diagnosis_evidence FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY evidence_write ON public.diagnosis_evidence FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY issues_read ON public.strategic_issues FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY issues_write ON public.strategic_issues FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY issue_sources_read ON public.strategic_issue_sources FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY issue_sources_write ON public.strategic_issue_sources FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY issue_links_read ON public.strategic_issue_links FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY issue_links_write ON public.strategic_issue_links FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));

CREATE POLICY weight_sets_read ON public.weight_sets FOR SELECT TO authenticated USING (true);
CREATE POLICY weight_sets_write ON public.weight_sets FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY pw_read ON public.priority_weights FOR SELECT TO authenticated USING (true);
CREATE POLICY pw_write ON public.priority_weights FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY sow_read ON public.strategic_objective_weights FOR SELECT TO authenticated USING (true);
CREATE POLICY sow_write ON public.strategic_objective_weights FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY pow_read ON public.phase_objective_weights FOR SELECT TO authenticated USING (true);
CREATE POLICY pow_write ON public.phase_objective_weights FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());