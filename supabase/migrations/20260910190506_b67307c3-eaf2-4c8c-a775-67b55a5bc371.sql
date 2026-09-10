ALTER TABLE public.strategic_objectives
  ADD COLUMN IF NOT EXISTS number integer,
  ADD COLUMN IF NOT EXISTS active_from_phase_id uuid REFERENCES public.strategy_phases(id),
  ADD COLUMN IF NOT EXISTS active_to_phase_id uuid REFERENCES public.strategy_phases(id),
  ADD COLUMN IF NOT EXISTS source_reference text;

ALTER TABLE public.phase_objectives
  ADD COLUMN IF NOT EXISTS number integer,
  ADD COLUMN IF NOT EXISTS source_reference text;

CREATE UNIQUE INDEX IF NOT EXISTS strategic_objectives_priority_number_key
  ON public.strategic_objectives(priority_id, number);
CREATE UNIQUE INDEX IF NOT EXISTS phase_objectives_so_phase_number_key
  ON public.phase_objectives(strategic_objective_id, phase_id, number);