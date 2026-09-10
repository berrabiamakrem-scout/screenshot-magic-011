import { ChevronLeft } from "lucide-react";

import heroImage from "@/assets/hero-scouts.jpg.asset.json";
import { contributionChain } from "@/data/impact37";

export function ContributionToImpact37() {
  return (
    <section className="card-surface relative overflow-hidden p-4">
      <img
        src={heroImage.url}
        alt=""
        aria-hidden
        className="pointer-events-none absolute inset-y-0 right-0 h-full w-2/5 object-cover opacity-30 [mask-image:linear-gradient(to_left,#000_20%,transparent_95%)]"
      />
      <div
        className="pointer-events-none absolute inset-0 bg-gradient-to-r from-surface/60 to-transparent"
        aria-hidden
      />
      <div className="relative">
        <h2 className="section-title">مساهمتك في أثر 37</h2>
        <p className="mt-1 max-w-md text-[0.72rem] leading-5 text-muted-foreground">
          كل نشاط منك يُساهم في تحقيق الاستراتيجية الوطنية. معاً نصنع تجربة شبابية أكثر تأثيراً.
        </p>

        <ol className="mt-3 flex flex-wrap items-center gap-1.5">
          {contributionChain.map((step, index) => (
            <li key={step} className="flex items-center gap-1.5">
              <span
                className={`rounded-lg border px-2 py-1 text-[0.68rem] font-semibold ${
                  index === contributionChain.length - 1
                    ? "border-transparent bg-navy text-primary-foreground"
                    : "border-border bg-secondary text-navy"
                }`}
              >
                {step}
              </span>
              {index < contributionChain.length - 1 && (
                <ChevronLeft className="size-3.5 text-teal" aria-hidden />
              )}
            </li>
          ))}
        </ol>

        <button
          type="button"
          className="mt-3 inline-flex items-center gap-2 rounded-lg border border-teal bg-surface px-3 py-1.5 text-[0.78rem] font-semibold text-teal transition-colors hover:bg-teal hover:text-primary-foreground"
        >
          اكتشف كيف تساهم
          <ChevronLeft className="size-4" aria-hidden />
        </button>
      </div>
    </section>
  );
}
