# IMPACT 37 — Data Architecture v2 (design only)

No interface changes. This revises the earlier blueprint against your detailed specification. Backend: Lovable Cloud (Postgres + Auth + Row Level Security + file storage).

Legend: **M** = master/reference data, **T** = transactional, **V** = versioned, **A** = approval workflow, **L** = audit-logged.

## 1. Organization — M, L
- `org_units` (PK id): name_ar, name_fr, code (unique), level (national/regional/local), parent_id → org_units, region_code, geo (lat/lng/governorate), active, archived_at, created_at. No region is hardcoded in app logic.
- `org_unit_closure` (PK unit_id+ancestor_id): depth. Rebuilt automatically; makes "my unit and all children" one indexed lookup inside access rules.

## 2. Strategic time and reference tree — M, V, L
- `strategies`: code, title, 2025–2037, version, status.
- `strategy_phases`: strategy_id, number 1–3, label, start_year, end_year.
- `seasons`: phase_id, label (2025–2026 …), start/end date, unique per phase. Four per phase; activities allowed in any season, past or future.
- `strategic_paths`: strategy_id, number, code, title_ar.
- `priorities`: path_id, number, code, title_ar.
- `strategic_objectives`: priority_id, code, title_ar — stable across the strategy.
- `phase_objectives`: strategic_objective_id, phase_id, code, title_ar, version, supersedes_id, status. New phase = new rows; old rows kept.

Path and priority for an activity are derived through this chain, never stored twice.

## 3. Reference data module (البيانات) — M, A(validation), L
One shared envelope instead of a dozen ad-hoc tables:
- `data_indicators_catalog`: code, name_ar, category (structures, membership, leaders, training, program, finance, population, youth, education, infrastructure, social/economic), unit_of_measure, description.
- `reference_data` (T): catalog_id, org_unit_id, season_id or year, value_numeric, value_text, breakdown JSONB (gender, age band, training level, qualification…), source, data_owner, validation_status (draft/validated/rejected), validated_by, notes, updated_at. Unique (catalog_id, org_unit_id, period, breakdown key).

This keeps every record with year/season, unit, source, value, unit of measure, owner, update date, validation status and notes — and lets any record be cited as diagnostic evidence.

## 4. Diagnosis — T, A, L
- `diagnoses`: org_unit_id, phase_id, season_id, type (swot/pestel), status, created_by, approved_by.
- `swot_items`: diagnosis_id, type (strength/weakness/opportunity/threat), analysis_area (الحوكمة، المالية، التدريب، البرنامج الكشفي، الإعلام والتسويق، الشراكات، القيادات/الشباب، الاستدامة), description, org_unit_id, phase_id, presence_score 1–10, impact_score 1–10, `result` generated = presence × impact (max 100), notes, status, created_by, approved_by.
- `pestel_items`: diagnosis_id, dimension (political…legal), description, influence (positive/negative/mixed), probability_score, impact_score, affected areas, source.
- `pestel_swot_links`: pestel_item_id ↔ swot_item_id.
- `diagnosis_evidence`: diagnostic item ↔ `reference_data` row or uploaded file.
- `strategic_issues`: org_unit_id, phase_id, title, description, rank, status.
- `strategic_issue_sources`: issue_id ↔ swot/pestel items (many-to-many).
- `strategic_issue_links`: issue_id ↔ priority and/or strategic_objective.

SWOT scores live only here. They are never reused as weights.

## 5. Strategic weights — M, V, A, L
Separate tables, separate names, no shared column with diagnosis:
- `weight_sets`: strategy_id, phase_id, version, status (draft/approved/active/archived), effective_from, change_reason, approved_by.
- `priority_weights`, `strategic_objective_weights`, `phase_objective_weights`: weight_set_id + target id + weight (numeric percent).

Rule enforced at activation: for each strategic objective, the sum of its phase objective weights equals that objective's weight exactly (3% → 0.5+0.7+0.6+0.5+0.7). No normalization to 100%. Drafts may be unbalanced; activation is blocked until balanced. Superseded sets are archived, never overwritten.

## 6. Indicators — M, V, L
- `indicators`: code, name_ar, description, phase_objective_id, type (quantitative/qualitative), unit, direction (higher_better/lower_better/maintain_range), calculation_method, source, verification_method, periodicity, responsible_unit_id, version, supersedes_id, status.
- `indicator_baselines`: indicator_id, org_unit_id, value, reference_year/date, source, methodology, status (adopted/needs_measurement/provisional/unavailable), validated_by. Never auto-filled.
- `indicator_targets` (V): indicator_id, scope (phase/season), phase_id or season_id, org_unit_id (null = national), target_value, version, effective_from.
- `indicator_results` (T, A): indicator_id, org_unit_id, season_id, activity_id (nullable), actual_value, qualitative_note, reported_by, status (pending_verification/approved/returned), reviewer_id, review_note, verified_at. Only approved rows enter official calculations.

Baseline, target and actual stay in three separate tables.

## 7. Plans and activities — T, A, L
- `plans`: org_unit_id, season_id, title, status, submitted_at, approved_by.
- `activities`: plan_id, org_unit_id, season_id, phase_id, strategic_objective_id, phase_objective_id, title, description, start_date, end_date, owner_id, expected_beneficiaries, budget (nullable), workflow_status (draft/submitted/approved/returned), progress_status. No fixed activity types.
- `activity_indicators`: activity_id, indicator_id (official) or custom_indicator_id, weight percent. Rule: weights of one activity sum to exactly 100 when the activity is submitted — any split allowed.
- `custom_indicators`: unit-specific indicators, allowed only where permission grants it.
- `activity_progress_history`: activity_id, from_status, to_status, percent, note NOT NULL, changed_by, changed_at, evidence_file_id. Full chronological history; percent derived from the status, never typed by the user.
- `evidence_files`: entity_type + entity_id, storage path, filename, uploaded_by.

Progress states fixed to لم يبدأ 0 / في الإعداد 25 / قيد التنفيذ 50 / متقدم 75 / منجز 100. Progress (execution) and achievement (indicator results) are separate columns in separate tables and are never merged.

## 8. Approvals — T, L
`approval_requests`: entity_type (activity / indicator_result / governance_date_change / weight_set / reference_data), entity_id, requested_by, requester_unit_id, approver_role, approver_unit_id, status (pending/approved/returned), decision_by, decision_at, reason, note. One trail for every workflow. Approver level derives from the requester's unit: local → regional, regional → national/monitoring.

## 9. Governance — M + T, A, L
- `governance_rules`: unit level, body/event type, frequency (months), notice periods — configurable, not hardcoded (national conference 48 months, supreme council 6 months, etc. entered as data).
- `governance_bodies`: org_unit_id, type (مؤتمر/مجلس/لجنة), name.
- `governance_events`: body_id, org_unit_id, type (conference/council/meeting), title, reference_date (original, never overwritten), approved_date, proposed_date, status, generated_from_rule_id.
- `governance_date_changes`: event_id, proposed_date, reason, report_file_id, requester_id, approver_id, decision_date, status — permanent history; the leader cannot replace an official date directly.
- `decisions`: event_id, text, owner, due_date, status.
- `minutes`: event_id, content, file_id.
- `notification_rules` + `reminders`: offsets (6 months, 3 months, 60 days, 30 days…) stored separately from event dates.

## 10. Users, roles, security
- `profiles`: full_name, phone, org_unit_id, active.
- `user_roles`: user_id, role, org_unit_id (scope). Roles in their own table — never on the profile — to prevent privilege escalation. Roles: PLATFORM_SUPER_ADMIN, STRATEGY_ADMIN, NATIONAL_MANAGER, REGIONAL_MANAGER, LOCAL_MANAGER, ACTIVITY_OWNER, REVIEWER, EVALUATOR, VIEWER.
- Two helper rules used by every policy: `can_access_unit(unit)` (read) and `can_manage_unit(unit)` (write), both via the closure table.
- Super admin: full access everywhere, every action logged. National roles: national scope per role. Regional: their region and children. Local: their own unit. All signed-in users: read-only access to approved national strategy, indicators and aggregated results. Not signed in: nothing.

## 11. Audit — L
`audit_log`: actor_id, action, entity_type, entity_id, old_value JSONB, new_value JSONB, reason, approval_request_id, occurred_at. Insert-only, written by a generic trigger on strategy, weights, indicators, targets, activities, approvals, governance dates, roles and settings.

## 12. National contribution readiness
Every fact row carries org_unit_id + season_id, and activity → phase objective → strategic objective → priority → path → strategy is a pure foreign-key walk combined with the active weight set. That is all "مساهمتك في أثر 37" and the three dashboards will need. No dashboard is built now.

## Conflicts and duplication resolved
1. **SWOT scores vs strategic weights** — completely separate tables; no shared column or table.
2. **Progress vs achievement** — separate tables; completion never implies achievement.
3. **Path/priority on activities** — derived through the objective chain, not stored on the activity, so they cannot drift.
4. **Reference data** — one catalog + one values table instead of ~12 near-identical tables.
5. **Approvals** — one workflow table instead of a status pair on each entity.
6. **Baseline/target/actual** — three tables, so a target revision never overwrites a baseline.
7. **Phase objectives changing per phase** — versioned rows with `supersedes_id`, never edited in place.
8. **Open item**: official strategic objectives, phase objectives, codes and official indicators are not in the material provided so far. Structure will be created empty; nothing will be invented. Only paths, priorities, vision, mission and values already confirmed from the strategy document will be seeded.

## Out of scope this step
No UI pages, no redesign of `face final`, no calculation engine, no dashboards.
