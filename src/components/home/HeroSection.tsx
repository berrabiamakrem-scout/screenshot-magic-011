import { Eye, Send, Gem } from "lucide-react";

import heroImage from "@/assets/hero-scouts.jpg.asset.json";
import impactLogo from "@/assets/impact37-logo.jpg.asset.json";
import { identity, mission, values, vision } from "@/data/impact37";

export function HeroSection() {
  return (
    <section className="card-surface overflow-hidden">
      <div className="grid gap-0 lg:grid-cols-[minmax(0,1.35fr)_minmax(0,1fr)]">
        {/* Right column (RTL first): welcome, logo, vision / mission / values */}
        <div className="order-2 flex flex-col gap-4 p-5 lg:order-1">
          <div className="flex flex-col-reverse items-start gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="font-display text-lg font-bold leading-snug text-navy sm:text-2xl">
                {identity.heroTitle}
              </h1>
              <p className="mt-1.5 text-sm font-medium text-navy/70 sm:text-base">
                {identity.heroSubtitle}
              </p>
            </div>
            <img
              src={impactLogo.url}
              alt="شعار أثر 37 – IMPACT 37"
              className="h-20 w-auto shrink-0 object-contain sm:h-24"
            />
          </div>

          <div className="grid gap-3 md:grid-cols-[minmax(0,1fr)_minmax(0,1.25fr)_minmax(0,0.9fr)]">
            <article className="rounded-xl border border-border bg-secondary/60 p-4">
              <header className="mb-2 flex items-center justify-end gap-2">
                <h2 className="font-display text-sm font-bold text-teal">{vision.title}</h2>
                <Eye className="size-4 text-teal" aria-hidden />
              </header>
              <p className="text-[0.78rem] leading-6 text-navy/85">{vision.text}</p>
            </article>

            <article className="rounded-xl border border-border bg-secondary/60 p-4">
              <header className="mb-2 flex items-center justify-end gap-2">
                <h2 className="font-display text-sm font-bold text-violet">{mission.title}</h2>
                <Send className="size-4 text-violet" aria-hidden />
              </header>
              <p className="max-h-44 overflow-y-auto text-[0.78rem] leading-6 text-navy/85">
                {mission.text}
              </p>
            </article>

            <article className="rounded-xl border border-border bg-secondary/60 p-4">
              <header className="mb-2 flex items-center justify-end gap-2">
                <h2 className="font-display text-sm font-bold text-green">{values.title}</h2>
                <Gem className="size-4 text-green" aria-hidden />
              </header>
              <p className="text-[0.8rem] leading-7 font-medium text-navy/85">
                {values.items.join(" · ")}
              </p>
            </article>
          </div>
        </div>

        {/* Left column (RTL last): scout photo */}
        <div className="relative order-1 min-h-52 lg:order-2 lg:min-h-full">
          <img
            src={heroImage.url}
            alt="قادة كشفيون تونسيون يتطلعون نحو الأفق"
            className="absolute inset-0 size-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-l from-transparent via-navy/10 to-navy/45" />
          <div className="relative p-5 text-end">
            <p className="font-display text-2xl font-bold text-white drop-shadow sm:text-3xl">
              {identity.heroOverlayLine1}
            </p>
            <p className="font-display text-2xl font-bold text-white drop-shadow sm:text-3xl">
              {identity.heroOverlayLine2}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
