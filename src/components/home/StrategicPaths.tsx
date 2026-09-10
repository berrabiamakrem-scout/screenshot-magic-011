import { BookOpen, Building2, Megaphone, Compass } from "lucide-react";

import { SectionHeader } from "@/components/layout/AppShell";
import { strategicPaths } from "@/data/impact37";
import { toneClasses } from "@/lib/tone";

const pathIcons = [BookOpen, Building2, Megaphone, Compass] as const;

export function StrategicPaths() {
  return (
    <section>
      <SectionHeader title="المسارات الاستراتيجية لأثر 37" action={{ label: "عرض جميع المسارات" }} />
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {strategicPaths.map((path, index) => {
          const Icon = pathIcons[index % pathIcons.length]!;
          const tone = toneClasses[path.tone];
          return (
            <article key={path.number} className="card-surface flex flex-col gap-3 p-5">
              <div className="flex items-start justify-between gap-3">
                <span
                  className={`rounded-lg px-2.5 py-1 font-display text-xs font-bold ${tone.badge}`}
                >
                  {path.number}
                </span>
                <span className={`rounded-xl p-2.5 ${tone.soft}`}>
                  <Icon className={`size-6 ${tone.text}`} aria-hidden />
                </span>
              </div>
              <h3 className={`font-display text-base font-bold ${tone.text}`}>{path.title}</h3>
              <p className="text-sm leading-7 text-muted-foreground">{path.description}</p>
            </article>
          );
        })}
      </div>
    </section>
  );
}
