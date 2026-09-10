export type Tone = "violet" | "navy" | "teal" | "green" | "amber";

type ToneClasses = {
  badge: string;
  text: string;
  soft: string;
  ring: string;
};

export const toneClasses: Record<Tone, ToneClasses> = {
  violet: {
    badge: "bg-violet text-primary-foreground",
    text: "text-violet",
    soft: "bg-violet-soft",
    ring: "ring-violet/15",
  },
  navy: {
    badge: "bg-navy text-primary-foreground",
    text: "text-navy",
    soft: "bg-navy-soft",
    ring: "ring-navy/15",
  },
  teal: {
    badge: "bg-teal text-primary-foreground",
    text: "text-teal",
    soft: "bg-teal-soft",
    ring: "ring-teal/15",
  },
  green: {
    badge: "bg-green text-primary-foreground",
    text: "text-green",
    soft: "bg-green-soft",
    ring: "ring-green/15",
  },
  amber: {
    badge: "bg-amber text-primary-foreground",
    text: "text-amber",
    soft: "bg-amber-soft",
    ring: "ring-amber/15",
  },
};
