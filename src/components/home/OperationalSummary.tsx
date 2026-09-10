import { CalendarClock, ListChecks, ClipboardList, Flag, Trophy, Gauge } from "lucide-react";

import { phases } from "@/data/impact37";
import { toneClasses, type Tone } from "@/lib/tone";

type Stat = {
  label: string;
  value: string;
  hint: string;
  icon: typeof Gauge;
  tone: Tone;
};

const stats: Stat[] = [
  {
    label: "التقدم العام",
    value: "68%",
    hint: "نحو تحقيق أثر 37",
    icon: Gauge,
    tone: "teal",
  },
  {
    label: "الإجمالي العام",
    value: "124",
    hint: "نشاطاً منجزاً (من 182)",
    icon: Trophy,
    tone: "amber",
  },
  {
    label: "المرحلة الحالية",
    value: phases.current,
    hint: "مرحلة التنفيذ",
    icon: Flag,
    tone: "navy",
  },
  {
    label: "الموسم الحالي",
    value: phases.season,
    hint: "الموسم الكشفي",
    icon: ClipboardList,
    tone: "violet",
  },
  {
    label: "الأنشطة",
    value: "48",
    hint: "نشاطاً قيد التنفيذ",
    icon: ListChecks,
    tone: "green",
  },
  {
    label: "الاستحقاقات القادمة",
    value: "12",
    hint: "خلال 30 يوماً",
    icon: CalendarClock,
    tone: "navy",
  },
];

export function OperationalSummary() {
  return (
    <section className="grid grid-cols-2 gap-2.5 md:grid-cols-3 lg:grid-cols-6">
      {stats.map((stat) => {
        const Icon = stat.icon;
        const tone = toneClasses[stat.tone];
        return (
          <article key={stat.label} className="card-surface p-3">
            <header className="mb-1 flex items-center justify-between gap-2">
              <h3 className="text-[0.72rem] font-semibold text-navy">{stat.label}</h3>
              <span className={`shrink-0 rounded-md p-1 ${tone.soft}`}>
                <Icon className={`size-3.5 ${tone.text}`} aria-hidden />
              </span>
            </header>
            <p className="font-display text-lg font-bold text-navy">{stat.value}</p>
            <p className="mt-0.5 text-[0.65rem] text-muted-foreground">{stat.hint}</p>
          </article>
        );
      })}
    </section>
  );
}
