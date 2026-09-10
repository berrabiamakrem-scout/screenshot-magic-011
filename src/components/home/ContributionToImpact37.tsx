import { ChevronLeft } from "lucide-react";

import heroImage from "@/assets/hero-scouts.jpg.asset.json";
import { contributionChain } from "@/data/impact37";

export function ContributionToImpact37() {
  return (
    <section className="card-surface relative overflow-hidden p-5">
      <img
        src={heroImage.url}
        alt=""
        aria-hidden
        className="pointer-events-none absolute inset-y-0 start-0 h-full w-1/3 object-cover opacity-20"
      />
      <div
        className="pointer-events-none absolute inset-0 bg-gradient-to-l from-transparent to-surface"
        aria-hidden
      />
      <div className="relative">
        <h2 className="section-title">مساهمتك في أثر 37</h2>
        <p className="mt-1.5 max-w-md text-[0.8rem] leading-6 text-muted-foreground">
          كل نشاط منك يُساهم في تحقيق الاستراتيجية الوطنية. معاً نصنع تجربة شبابية أكثر تأثيراً.
        </p>

        <ol className="mt-4 flex flex-wrap items-center gap-1.5">
          {contributionChain.map((step, index) => (
            <li key={step} className="flex items-center gap-1.5">
              <span
                className={`rounded-lg border px-2.5 py-1.5 text-[0.75rem] font-semibold ${
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
          className="mt-4 inline-flex items-center gap-2 rounded-lg border border-teal bg-surface px-4 py-2 text-sm font-semibold text-teal transition-colors hover:bg-teal hover:text-primary-foreground"
        >
          اكتشف كيف تساهم
          <ChevronLeft className="size-4" aria-hidden />
        </button>
      </div>
    </section>
  );
}
