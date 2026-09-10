import {
  TrendingUp,
  Tent,
  Landmark,
  Coins,
  Megaphone,
  Handshake,
  Users,
  Leaf,
  type LucideIcon,
} from "lucide-react";

import { SectionHeader } from "@/components/layout/AppShell";
import { strategicPriorities, type StrategicPriority } from "@/data/impact37";
import { toneClasses } from "@/lib/tone";

const icons: Record<StrategicPriority["icon"], LucideIcon> = {
  training: TrendingUp,
  programme: Tent,
  governance: Landmark,
  resources: Coins,
  media: Megaphone,
  partnerships: Handshake,
  youth: Users,
  sustainability: Leaf,
};

export function StrategicPriorities() {
  return (
    <section>
      <SectionHeader
        title="الأولويات الاستراتيجية الثمانية"
        action={{ label: "عرض جميع الأولويات" }}
      />
      <div className="grid gap-4 grid-cols-2 lg:grid-cols-4 xl:grid-cols-8">
        {strategicPriorities.map((priority) => {
          const Icon = icons[priority.icon];
          const tone = toneClasses[priority.tone];
          return (
            <article
              key={priority.number}
              className="card-surface flex flex-col items-center gap-2 p-4 text-center"
            >
              <span
                className={`self-start rounded-lg px-2 py-0.5 font-display text-[0.7rem] font-bold ${tone.badge}`}
              >
                {priority.number}
              </span>
              <span className={`rounded-xl p-2.5 ${tone.soft}`}>
                <Icon className={`size-6 ${tone.text}`} aria-hidden />
              </span>
              <h3 className="text-sm font-semibold leading-6 text-navy">
                أولوية {priority.title}
              </h3>
              <p className="mt-auto text-[0.7rem] leading-5 text-muted-foreground">
                {priority.path}
              </p>
            </article>
          );
        })}
      </div>
    </section>
  );
}
