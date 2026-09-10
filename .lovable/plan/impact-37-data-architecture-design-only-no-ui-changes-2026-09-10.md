# IMPACT 37 — Data Architecture (design only, no UI changes)

No interface changes in this step. This is the database blueprint to approve before anything is created.

## Backend

Lovable Cloud (Postgres + Auth + Row Level Security + storage for evidence files). Enabled only after approval.

## 1. Organization

- `org_units` — id, name_ar, name_fr, level (`national` | `regional` | `local`), parent_id → org_units, code, region_code, active. Self-referencing tree; national is the single root.
- `org_unit_closure` (unit_id, ancestor_id, depth) — materialized ancestry so "my unit and all children" checks are one indexed lookup instead of recursion inside RLS.

## 2. Strategic reference

- `strategies` — code, title, start_year, end_year, status, version.
- `strategy_phases` — strategy_id, name_ar, order, start/end date, status.
- `seasons` — strategy_id, label (e.g. 2025/2026), phase_id, start/end date.
- `strategic_paths` — strategy_id, number (1–4), title_ar, description.
- `priorities` — path_id, number (1–8), title_ar, description.
- `strategic_objectives` — priority_id, code, title_ar, description.
- `phase_objectives` — strategic_objective_id, phase_id, code, title_ar.

All strategic codes stored as a `code` text column, unique per parent.

## 3. Reference data

- `unit_membership_stats` — org_unit_id, season_id, counts by section, leaders count.
- `leaders`, `trainings`, `training_participations`.
- `program_data` — scout program activity/section metrics per unit and season.
- `financial_records` — unit_id, season_id, category, amount, source.
- `context_data` — unit_id, year, population, youth_population, schools_count, plus a JSONB `extra` for other social/economic indicators.

Each reference table is keyed by (org_unit_id, season/year) with a unique constraint to prevent duplicate entries.

## 4. Diagnosis

- `diagnoses` — org_unit_id, season_id, type (`swot` | `pestel`), status, created_by.
- `swot_items` — diagnosis_id, category (strength/weakness/opportunity/threat), internal_area (governance, finance, training, program, media, partnerships, youth_leaders, sustainability), statement, presence_score 1–10, impact_score 1–10, `result` as a generated column = presence × impact.
- `pestel_items` — diagnosis_id, dimension (political, economic, social, technological, environmental, legal), statement, effect direction, severity.
- `strategic_issues` — diagnosis_id, title, description, linked priority/objective, rank.

Check constraints enforce the 1–10 score range and valid category values.

## 5. Weights (kept fully separate from SWOT scores)

- `weight_sets` — strategy_id, version, status (`draft` | `active` | `archived`), effective_from, created_by. Only one active set per strategy.
- `priority_weights` — weight_set_id, priority_id, weight.
- `strategic_objective_weights` — weight_set_id, strategic_objective_id, weight.
- `phase_objective_weights` — weight_set_id, phase_objective_id, weight.

Rule: within a weight set, the sum of phase objective weights under a strategic objective must equal that strategic objective's weight. Enforced by a validation function run when a weight set is activated (a per-row trigger cannot see a complete set mid-edit). Draft sets may be temporarily unbalanced; activation is blocked until balanced.

## 6. Indicators

- `indicators` — owner (strategic_objective_id or phase_objective_id), code, title_ar, type (`quantitative` | `qualitative`), unit, direction (`increase` | `decrease` | `maintain`), calculation_method, verification_method, evidence_requirement, baseline_value, baseline_date.
- `indicator_targets` — indicator_id, scope (`phase` | `season`), phase_id or season_id, org_unit_id (nullable for national), target_value.
- `indicator_results` — indicator_id, org_unit_id, season_id, actual_value, qualitative_note, reported_by, reported_at, status (`pending_verification` | `approved` | `returned`), reviewer_id, review_note.

## 7. Plans and activities

- `plans` — org_unit_id, season_id, title, status, submitted_at, approved_by.
- `activities` — plan_id, org_unit_id, title_ar, description, planned_start/end, actual dates, owner_id, status (`draft` | `submitted` | `approved` | `returned`), progress (0/25/50/75/100), linked priority and phase_objective.
- `activity_indicators` — activity_id, indicator_id, weight (contribution of this activity to the indicator).
- `activity_progress_history` — activity_id, from_progress, to_progress, note (NOT NULL — mandatory), created_by, created_at.
- `evidence_files` — polymorphic (entity_type, entity_id), storage path, filename, uploaded_by.

Progress values restricted by check constraint to {0, 25, 50, 75, 100}, matching لم يبدأ / في الإعداد / قيد التنفيذ / متقدم / منجز.

## 8. Approvals

- `approval_requests` — entity_type (`activity` | `indicator_result` | `governance_date_change`), entity_id, requested_by, requester_unit_id, approver_role, status (`pending` | `approved` | `returned`), decision_by, decision_at, reason, note.

One shared workflow table so activities, indicator results, and governance date changes follow the same audit trail. Approval level is derived from the requester's unit level: local → regional approver, regional → national/monitoring approver.

## 9. Governance

- `governance_bodies` — org_unit_id, type (`conference` | `council` | `committee`).
- `governance_events` — body_id, org_unit_id, title, type (`conference` | `council` | `meeting`), original_date, proposed_date, approved_date, status, reason, report_file_id.
- `decisions` — event_id, text, owner, due_date, status.
- `minutes` — event_id, content, file_id.
- `reminders` — entity reference, due_date, sent_at, channel.

Date changes go through `approval_requests` with the original/proposed/approved dates preserved on the event row.

## 10. Users and roles

- `profiles` — user_id (→ auth users), full_name, org_unit_id, phone, active.
- `app_role` enum: PLATFORM_SUPER_ADMIN, STRATEGY_ADMIN, NATIONAL_MANAGER, REGIONAL_MANAGER, LOCAL_MANAGER, ACTIVITY_OWNER, REVIEWER, EVALUATOR, VIEWER.
- `user_roles` — user_id, role, org_unit_id (scope of the role), unique (user_id, role, org_unit_id).

Roles live in their own table, never on the profile, to avoid privilege escalation. A security-definer function `has_role(user, role, unit)` and `can_access_unit(user, unit)` are used by all policies.

## 11. Security (RLS)

Every table has RLS enabled. Access is decided by two helper functions rather than repeated logic:

- PLATFORM_SUPER_ADMIN: full read/write everywhere.
- Regional users: read/write rows whose org_unit is their region or any descendant (closure table lookup).
- Local users: read/write rows for their own unit only.
- National users: read everything; write according to role.
- All authenticated users: read-only access to strategy, phases, paths, priorities, objectives, indicators, and national indicator targets.
- Anonymous users: no access.

## 12. Audit

- `audit_log` — actor_id, occurred_at, entity_type, entity_id, action, old_value JSONB, new_value JSONB, reason, approval_request_id. Written by a generic trigger attached to every business table. Insert-only; no updates or deletes.

## 13. Versioning

Strategy, weights, and targets are versioned rather than overwritten: `weight_sets` carry versions, `strategies` carry a version and status, and `indicator_targets` carry a `revision` with the superseded row archived. `strategy_reviews` records each review cycle (date, scope, outcome, resulting version).

## 14. Dashboard readiness

No dashboards built now. The model supports them later because every fact row (activity, indicator result, progress) carries org_unit_id and season_id, and contribution can be computed by walking activity → indicator → phase objective → strategic objective → priority → path with the active weight set.

## Indexes

Foreign keys on all child tables; composite indexes on (org_unit_id, season_id) for plans, activities, indicator results and reference data; (entity_type, entity_id) on evidence files, approvals and audit log; closure table indexed both directions.

## Out of scope in this step

No UI pages, no redesign, no calculation engine, no seed data.
