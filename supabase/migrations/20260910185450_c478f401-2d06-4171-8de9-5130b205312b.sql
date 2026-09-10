ALTER TABLE public.priorities
  ADD CONSTRAINT priorities_path_number_unique UNIQUE (path_id, number),
  ADD CONSTRAINT priorities_path_code_unique UNIQUE (path_id, code);

GRANT ALL ON public.priorities TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.priorities TO authenticated;