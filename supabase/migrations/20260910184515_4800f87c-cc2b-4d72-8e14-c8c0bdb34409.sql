INSERT INTO public.strategies (code, title_ar, start_year, end_year, status)
VALUES ('IMPACT37', 'أثر 37 – الاستراتيجية الوطنية للكشافة التونسية', 2025, 2037, 'active');

INSERT INTO public.strategy_phases (strategy_id, number, label, start_year, end_year)
SELECT s.id, v.number, v.label, v.sy, v.ey
FROM public.strategies s,
(VALUES (1,'المرحلة الأولى 2025–2029',2025,2029),
        (2,'المرحلة الثانية 2029–2033',2029,2033),
        (3,'المرحلة الثالثة 2033–2037',2033,2037)) AS v(number,label,sy,ey)
WHERE s.code = 'IMPACT37';

INSERT INTO public.seasons (phase_id, label, start_date, end_date)
SELECT p.id,
       (y::text || '–' || (y+1)::text),
       make_date(y, 9, 1),
       make_date(y+1, 8, 31)
FROM public.strategy_phases p
CROSS JOIN LATERAL generate_series(p.start_year, p.end_year - 1) AS y;

INSERT INTO public.strategic_paths (strategy_id, number, code, title_ar)
SELECT s.id, v.n, v.c, v.t
FROM public.strategies s,
(VALUES (1,'P01','مسار التعليم المبتكر'),
        (2,'P02','مسار منظمة ملائمة للهدف'),
        (3,'P03','مسار منظمة مؤثرة'),
        (4,'P04','مسار منظمة قادرة على التكيف')) AS v(n,c,t)
WHERE s.code = 'IMPACT37';

INSERT INTO public.priorities (path_id, number, code, title_ar)
SELECT sp.id, v.n, v.c, v.t
FROM (VALUES
  (1,1,'PR01','التدريب وبناء القدرات'),
  (1,2,'PR02','البرنامج الكشفي'),
  (2,3,'PR03','الحوكمة والتطوير المؤسسي'),
  (2,4,'PR04','الموارد (المالية والبشرية)'),
  (3,5,'PR05','الإعلام والتسويق'),
  (3,6,'PR06','الشراكات والعلاقات الخارجية'),
  (4,7,'PR07','الشباب'),
  (4,8,'PR08','الاستدامة')) AS v(path_number,n,c,t)
JOIN public.strategic_paths sp ON sp.number = v.path_number;