import { SectionHeader } from "@/components/layout/AppShell";
import { strategicPriorities } from "@/data/impact37";
import { toneClasses } from "@/lib/tone";

import pri1 from "@/assets/pri-1.png.asset.json";
import pri2 from "@/assets/pri-2.png.asset.json";
import pri3 from "@/assets/pri-3.png.asset.json";
import pri4 from "@/assets/pri-4.png.asset.json";
import pri5 from "@/assets/pri-5.png.asset.json";
import pri6 from "@/assets/pri-6.png.asset.json";
import pri7 from "@/assets/pri-7.png.asset.json";
import pri8 from "@/assets/pri-8.png.asset.json";

const priorityIcons = [pri1, pri2, pri3, pri4, pri5, pri6, pri7, pri8];

export function StrategicPriorities() {
  return (
    <section>
      <SectionHeader
        title="الأولويات الاستراتيجية الثمانية"
        action={{ label: "عرض جميع الأولويات" }}
      />
      <div className="grid grid-cols-2 gap-2.5 sm:grid-cols-4 lg:grid-cols-8">
        {strategicPriorities.map((priority, index) => {
          const tone = toneClasses[priority.tone];
          const icon = priorityIcons[index]!;
          return (
            <article
              key={priority.number}
              className="card-surface flex flex-col items-center gap-1 p-2 text-center"
            >
              <span
                className={`self-end rounded-md px-1.5 py-0.5 font-display text-[0.62rem] font-bold ${tone.badge}`}
              >
                {priority.number}
              </span>
              <img
                src={icon.url}
                alt=""
                aria-hidden
                className="h-9 w-auto object-contain mix-blend-multiply"
              />
              <h3 className="text-[0.7rem] font-semibold leading-4 text-navy">{priority.title}</h3>
            </article>
          );
        })}
      </div>
    </section>
  );
}
