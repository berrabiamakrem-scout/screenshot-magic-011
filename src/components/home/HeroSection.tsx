import { Eye, Send, Gem } from "lucide-react";

import heroImage from "@/assets/hero-scouts.jpg.asset.json";
import impactLogo from "@/assets/impact37-logo.jpg.asset.json";
import { identity, mission, values, vision } from "@/data/impact37";

export function HeroSection() {
  return (
    <section className="card-surface overflow-hidden">
      <div className="grid gap-0 lg:grid-cols-[minmax(0,1.35fr)_minmax(0,1fr)]">
        {/* Right column (RTL first): welcome, logo, vision / mission / values */}
        <div className="order-2 flex flex-col gap-3 p-4 lg:order-1">
          <div className="flex flex-col-reverse items-start gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="font-display text-base font-bold leading-snug text-navy sm:text-xl">
                {identity.heroTitle}
              </h1>
              <p className="mt-1 text-[0.8rem] font-medium text-navy/70 sm:text-sm">
                {identity.heroSubtitle}
              </p>
            </div>
            <img
              src={impactLogo.url}
              alt="شعار أثر 37 – IMPACT 37"
              className="h-14 w-auto shrink-0 object-contain sm:h-16"
            />
          </div>

          <div className="grid gap-2.5 md:grid-cols-[minmax(0,0.85fr)_minmax(0,1.6fr)_minmax(0,0.6fr)]">
            <article className="rounded-xl border border-border bg-secondary/60 p-3">
              <header className="mb-1 flex items-center justify-end gap-2">
                <h2 className="font-display text-[0.8rem] font-bold text-teal">{vision.title}</h2>
                <Eye className="size-3.5 text-teal" aria-hidden />
              </header>
              <p className="text-[0.7rem] leading-5 text-navy/85">{vision.text}</p>
            </article>

            <article className="rounded-xl border border-border bg-secondary/60 p-3">
              <header className="mb-1 flex items-center justify-end gap-2">
                <h2 className="font-display text-[0.8rem] font-bold text-violet">{mission.title}</h2>
                <Send className="size-3.5 text-violet" aria-hidden />
              </header>
              <p className="text-[0.66rem] leading-[1.35rem] text-navy/85">{mission.text}</p>
            </article>

            <article className="rounded-xl border border-border bg-secondary/60 p-3">
              <header className="mb-1 flex items-center justify-end gap-2">
                <h2 className="font-display text-[0.8rem] font-bold text-green">{values.title}</h2>
                <Gem className="size-3.5 text-green" aria-hidden />
              </header>
              <p className="text-[0.72rem] leading-6 font-medium text-navy/85">
                {values.items.join(" · ")}
              </p>
            </article>
          </div>
        </div>

        {/* Left column (RTL last): scout photo */}
        <div className="relative order-1 min-h-40 lg:order-2 lg:min-h-full">
          <img
            src={heroImage.url}
            alt="قادة كشفيون تونسيون يتطلعون نحو الأفق"
            className="absolute inset-0 size-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-l from-transparent via-navy/10 to-navy/45" />
          <div className="relative p-4 text-end">
            <p className="font-display text-lg font-bold text-white drop-shadow sm:text-2xl">
              {identity.heroOverlayLine1}
            </p>
            <p className="font-display text-lg font-bold text-white drop-shadow sm:text-2xl">
              {identity.heroOverlayLine2}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
