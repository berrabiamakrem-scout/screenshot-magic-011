import { Eye, Send, Gem } from "lucide-react";

import { mission, values, vision } from "@/data/impact37";

export function VisionMissionValues() {
  return (
    <section className="grid gap-4 md:grid-cols-3">
      <article className="card-surface p-5">
        <header className="mb-3 flex items-center gap-2">
          <Eye className="size-5 text-teal" aria-hidden />
          <h2 className="section-title">{vision.title}</h2>
        </header>
        <p className="text-sm leading-7 text-navy/85">{vision.text}</p>
      </article>

      <article className="card-surface p-5 md:col-span-1">
        <header className="mb-3 flex items-center gap-2">
          <Send className="size-5 text-violet" aria-hidden />
          <h2 className="section-title">{mission.title}</h2>
        </header>
        <p className="max-h-56 overflow-y-auto text-sm leading-7 text-navy/85">{mission.text}</p>
      </article>

      <article className="card-surface p-5">
        <header className="mb-3 flex items-center gap-2">
          <Gem className="size-5 text-green" aria-hidden />
          <h2 className="section-title">{values.title}</h2>
        </header>
        <ul className="flex flex-wrap gap-2">
          {values.items.map((value) => (
            <li
              key={value}
              className="rounded-lg bg-navy-soft px-3 py-1.5 text-sm font-medium text-navy"
            >
              {value}
            </li>
          ))}
        </ul>
      </article>
    </section>
  );
}
