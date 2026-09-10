import { ChevronLeft, Flag } from "lucide-react";

import { phases } from "@/data/impact37";

export function CurrentPhaseCard() {
  return (
    <section className="card-surface flex flex-col gap-3 p-5">
      <header className="flex items-center justify-between gap-2">
        <h2 className="section-title">المرحلة الحالية {phases.current}</h2>
        <Flag className="size-4 text-violet" aria-hidden />
      </header>
      <p className="text-[0.78rem] leading-6 text-muted-foreground">
        ترسيخ الأسس وتعزيز التنفيذ عبر المسارات الاستراتيجية لأثر 37 لتحقيق الأثر الملموس في حياة
        الفتية والشباب.
      </p>
      <div className="flex items-center gap-3">
        <span className="font-display text-base font-bold text-teal">68%</span>
        <div className="h-2 flex-1 overflow-hidden rounded-full bg-secondary">
          <div className="h-full rounded-full bg-teal" style={{ width: "68%" }} />
        </div>
      </div>
      <div className="flex items-center justify-between gap-2">
        <p className="text-[0.75rem] text-muted-foreground">نحن في مرحلة التنفيذ</p>
        <button
          type="button"
          className="inline-flex items-center gap-1.5 rounded-lg border border-border px-3 py-1.5 text-[0.75rem] font-semibold text-navy transition-colors hover:border-teal hover:text-teal"
        >
          عرض تفاصيل المرحلة
          <ChevronLeft className="size-3.5" aria-hidden />
        </button>
      </div>
    </section>
  );
}
