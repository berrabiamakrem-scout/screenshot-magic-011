import { ChevronLeft } from "lucide-react";

import { contributionChain } from "@/data/impact37";

export function ContributionToImpact37() {
  return (
    <section className="card-surface p-6">
      <h2 className="section-title">مساهمتك في أثر 37</h2>
      <p className="mt-2 max-w-3xl text-sm leading-7 text-muted-foreground">
        كل نشاط منك يُساهم في تحقيق الاستراتيجية الوطنية. معاً نصنع تجربة شبابية أكثر تأثيراً.
      </p>

      <ol className="mt-5 flex flex-wrap items-center gap-2">
        {contributionChain.map((step, index) => (
          <li key={step} className="flex items-center gap-2">
            <span
              className={`rounded-lg border px-3 py-2 text-sm font-semibold ${
                index === contributionChain.length - 1
                  ? "border-transparent bg-navy text-primary-foreground"
                  : "border-border bg-secondary text-navy"
              }`}
            >
              {step}
            </span>
            {index < contributionChain.length - 1 && (
              <ChevronLeft className="size-4 text-teal" aria-hidden />
            )}
          </li>
        ))}
      </ol>

      <button
        type="button"
        className="mt-6 inline-flex items-center gap-2 rounded-lg bg-teal px-4 py-2.5 text-sm font-semibold text-primary-foreground transition-colors hover:bg-navy"
      >
        اكتشف كيف تساهم
        <ChevronLeft className="size-4" aria-hidden />
      </button>
    </section>
  );
}
