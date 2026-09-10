import { SectionHeader } from "@/components/layout/AppShell";
import { strategicPaths } from "@/data/impact37";
import { toneClasses } from "@/lib/tone";

import path1 from "@/assets/path-1.png.asset.json";
import path2 from "@/assets/path-2.png.asset.json";
import path3 from "@/assets/path-3.png.asset.json";
import path4 from "@/assets/path-4.png.asset.json";

const pathIcons = [path1, path2, path3, path4];

export function StrategicPaths() {
  return (
    <section>
      <SectionHeader title="المسارات الاستراتيجية لأثر 37" action={{ label: "عرض جميع المسارات" }} />
      <div className="grid gap-2.5 sm:grid-cols-2 xl:grid-cols-4">
        {strategicPaths.map((path, index) => {
          const tone = toneClasses[path.tone];
          const icon = pathIcons[index]!;
          return (
            <article key={path.number} className="card-surface flex flex-col gap-1.5 p-3">
              <div className="flex items-center justify-between gap-2">
                <h3 className={`font-display text-[0.82rem] font-bold ${tone.text}`}>
                  {path.title}
                </h3>
                <span
                  className={`shrink-0 rounded-md px-1.5 py-0.5 font-display text-[0.65rem] font-bold ${tone.badge}`}
                >
                  {path.number}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <p className="line-clamp-3 flex-1 text-[0.7rem] leading-5 text-muted-foreground">
                  {path.description}
                </p>
                <img
                  src={icon.url}
                  alt=""
                  aria-hidden
                  className="h-12 w-14 shrink-0 object-contain mix-blend-multiply"
                />
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}
