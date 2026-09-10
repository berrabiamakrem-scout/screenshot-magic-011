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
      <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-2">
        {actions.map((action) => {
          const Icon = action.icon;
          const tone = toneClasses[action.tone];
          return (
            <button
              key={action.label}
              type="button"
              className="flex items-center gap-3 rounded-xl border border-border bg-surface px-4 py-3 text-start text-sm font-semibold text-navy transition-colors hover:border-teal hover:bg-secondary"
            >
              <span className={`rounded-lg p-2 ${tone.soft}`}>
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
