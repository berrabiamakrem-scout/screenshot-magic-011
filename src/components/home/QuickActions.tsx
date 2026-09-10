import { Plus, Search, BarChart3, CalendarClock, type LucideIcon } from "lucide-react";

import { toneClasses, type Tone } from "@/lib/tone";

const actions: { label: string; icon: LucideIcon; tone: Tone }[] = [
  { label: "إضافة نشاط", icon: Plus, tone: "green" },
  { label: "فتح التشخيص", icon: Search, tone: "teal" },
  { label: "عرض خطتي", icon: BarChart3, tone: "violet" },
  { label: "الاستحقاقات القادمة", icon: CalendarClock, tone: "navy" },
];

export function QuickActions() {
  return (
    <section className="card-surface p-6">
      <h2 className="section-title">إجراءات سريعة</h2>
      <div className="mt-4 grid gap-2.5 sm:grid-cols-2">
        {actions.map((action) => {
          const Icon = action.icon;
          const tone = toneClasses[action.tone];
          return (
            <button
              key={action.label}
              type="button"
              className="flex items-center gap-2 rounded-xl border border-border bg-surface px-3 py-2.5 text-start text-[0.78rem] font-semibold text-navy transition-colors hover:border-teal hover:bg-secondary"
            >
              <span className={`shrink-0 rounded-lg p-1.5 ${tone.soft}`}>
                <Icon className={`size-4 ${tone.text}`} aria-hidden />
              </span>
              {action.label}
            </button>

          );
        })}
      </div>
    </section>
  );
}
