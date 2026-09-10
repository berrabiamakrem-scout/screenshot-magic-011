UPDATE public.seasons s
SET start_date = make_date(split_part(s.label, '–', 1)::int, 10, 1),
    end_date   = make_date(split_part(s.label, '–', 2)::int, 9, 30)
WHERE s.label ~ '^[0-9]{4}–[0-9]{4}$';