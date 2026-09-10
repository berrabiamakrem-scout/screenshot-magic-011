import heroImage from "@/assets/hero-scouts.jpg.asset.json";
import impactLogo from "@/assets/impact37-logo.jpg.asset.json";
import { identity } from "@/data/impact37";

export function HeroSection() {
  return (
    <section className="card-surface overflow-hidden">
      <div className="grid gap-0 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.1fr)]">
        <div className="relative min-h-56 lg:min-h-full">
          <img
            src={heroImage.url}
            alt="قادة كشفيون تونسيون يتطلعون نحو الأفق عند الشروق"
            width={1920}
            height={912}
            className="absolute inset-0 size-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-l from-navy/70 via-navy/25 to-transparent" />
          <div className="relative p-6 text-start">
            <p className="font-display text-2xl font-bold text-white drop-shadow sm:text-3xl">
              {identity.heroOverlayLine1}
            </p>
            <p className="font-display text-2xl font-bold text-white drop-shadow sm:text-3xl">
              {identity.heroOverlayLine2}
            </p>
          </div>
        </div>

        <div className="flex flex-col gap-5 p-6">
          <div className="flex flex-col-reverse items-start gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="font-display text-xl font-bold leading-snug text-navy sm:text-2xl">
                {identity.heroTitle}
              </h1>
              <p className="mt-2 text-sm text-muted-foreground sm:text-base">
                {identity.heroSubtitle}
              </p>
            </div>
            <img
              src={impactLogo.url}
              alt="شعار أثر 37 – IMPACT 37"
              className="h-24 w-auto shrink-0 object-contain sm:h-28"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
