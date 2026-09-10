CREATE TABLE public.governance_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  level public.org_level NOT NULL,
  body_type text NOT NULL,
  event_type text NOT NULL,
  frequency_months int,
  notice_days int,
  description_ar text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.governance_bodies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  type text NOT NULL,
  name_ar text NOT NULL,
  rule_id uuid REFERENCES public.governance_rules(id) ON DELETE SET NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.governance_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  body_id uuid REFERENCES public.governance_bodies(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text,
  reference_date date NOT NULL,
  approved_date date,
  proposed_date date,
  status text NOT NULL DEFAULT 'planned',
  generated_from_rule_id uuid REFERENCES public.governance_rules(id) ON DELETE SET NULL,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_gov_events_unit ON public.governance_events(org_unit_id);

CREATE TABLE public.governance_date_changes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.governance_events(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  previous_date date,
  proposed_date date NOT NULL,
  reason text NOT NULL,
  report_file_id uuid REFERENCES public.evidence_files(id) ON DELETE SET NULL,
  requester_id uuid NOT NULL DEFAULT auth.uid(),
  approver_id uuid,
  decision_date timestamptz,
  status public.workflow_status NOT NULL DEFAULT 'submitted',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.governance_decisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.governance_events(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  text_ar text NOT NULL,
  owner text,
  due_date date,
  status text NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.governance_minutes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.governance_events(id) ON DELETE CASCADE,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  content text,
  file_id uuid REFERENCES public.evidence_files(id) ON DELETE SET NULL,
  created_by uuid DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.notification_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type text NOT NULL,
  event_type text,
  offset_days int NOT NULL,
  channel text NOT NULL DEFAULT 'in_app',
  message_template text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.reminders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_id uuid REFERENCES public.notification_rules(id) ON DELETE SET NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  org_unit_id uuid NOT NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  due_at timestamptz NOT NULL,
  sent_at timestamptz,
  recipient_id uuid,
  message text,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_reminders_due ON public.reminders(due_at) WHERE sent_at IS NULL;

CREATE TABLE public.audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid DEFAULT auth.uid(),
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  old_value jsonb,
  new_value jsonb,
  reason text,
  approval_request_id uuid,
  occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_entity ON public.audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_time ON public.audit_log(occurred_at);

CREATE OR REPLACE FUNCTION public.audit_trigger()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $fn$
BEGIN
  INSERT INTO public.audit_log (actor_id, action, entity_type, entity_id, old_value, new_value)
  VALUES (
    auth.uid(), lower(TG_OP), TG_TABLE_NAME,
    COALESCE((to_jsonb(NEW)->>'id')::uuid, (to_jsonb(OLD)->>'id')::uuid),
    CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) END,
    CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) END
  );
  RETURN NULL;
END;
$fn$;
REVOKE ALL ON FUNCTION public.audit_trigger() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER trg_audit_activities AFTER INSERT OR UPDATE OR DELETE ON public.activities FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_results AFTER INSERT OR UPDATE OR DELETE ON public.indicator_results FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_indicators AFTER INSERT OR UPDATE OR DELETE ON public.indicators FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_targets AFTER INSERT OR UPDATE OR DELETE ON public.indicator_targets FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_weight_sets AFTER INSERT OR UPDATE OR DELETE ON public.weight_sets FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_approvals AFTER INSERT OR UPDATE OR DELETE ON public.approval_requests FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_gov_events AFTER INSERT OR UPDATE OR DELETE ON public.governance_events FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_gov_date_changes AFTER INSERT OR UPDATE OR DELETE ON public.governance_date_changes FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_user_roles AFTER INSERT OR UPDATE OR DELETE ON public.user_roles FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
CREATE TRIGGER trg_audit_strategies AFTER INSERT OR UPDATE OR DELETE ON public.strategies FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();

CREATE TRIGGER trg_gov_rules_updated BEFORE UPDATE ON public.governance_rules FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_gov_bodies_updated BEFORE UPDATE ON public.governance_bodies FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_gov_events_updated BEFORE UPDATE ON public.governance_events FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_gov_decisions_updated BEFORE UPDATE ON public.governance_decisions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_gov_minutes_updated BEFORE UPDATE ON public.governance_minutes FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER trg_notif_rules_updated BEFORE UPDATE ON public.notification_rules FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE, DELETE ON public.governance_rules, public.governance_bodies,
  public.governance_events, public.governance_date_changes, public.governance_decisions,
  public.governance_minutes, public.notification_rules, public.reminders TO authenticated;
GRANT SELECT ON public.audit_log TO authenticated;
GRANT ALL ON public.governance_rules, public.governance_bodies, public.governance_events,
  public.governance_date_changes, public.governance_decisions, public.governance_minutes,
  public.notification_rules, public.reminders, public.audit_log TO service_role;

ALTER TABLE public.governance_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_bodies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_date_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.governance_minutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY gov_rules_read ON public.governance_rules FOR SELECT TO authenticated USING (true);
CREATE POLICY gov_rules_write ON public.governance_rules FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());
CREATE POLICY notif_rules_read ON public.notification_rules FOR SELECT TO authenticated USING (true);
CREATE POLICY notif_rules_write ON public.notification_rules FOR ALL TO authenticated USING (public.is_strategy_admin()) WITH CHECK (public.is_strategy_admin());

CREATE POLICY gov_bodies_read ON public.governance_bodies FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY gov_bodies_write ON public.governance_bodies FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY gov_events_read ON public.governance_events FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY gov_events_write ON public.governance_events FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY gov_dc_read ON public.governance_date_changes FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY gov_dc_insert ON public.governance_date_changes FOR INSERT TO authenticated WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY gov_dc_update ON public.governance_date_changes FOR UPDATE TO authenticated USING (public.can_access_unit(org_unit_id)) WITH CHECK (public.can_access_unit(org_unit_id));
CREATE POLICY gov_dec_read ON public.governance_decisions FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY gov_dec_write ON public.governance_decisions FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY gov_min_read ON public.governance_minutes FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id));
CREATE POLICY gov_min_write ON public.governance_minutes FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));
CREATE POLICY reminders_read ON public.reminders FOR SELECT TO authenticated USING (public.can_access_unit(org_unit_id) OR recipient_id = auth.uid());
CREATE POLICY reminders_write ON public.reminders FOR ALL TO authenticated USING (public.can_manage_unit(org_unit_id)) WITH CHECK (public.can_manage_unit(org_unit_id));

CREATE POLICY audit_read ON public.audit_log FOR SELECT TO authenticated USING (public.is_super_admin());