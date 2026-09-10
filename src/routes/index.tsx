import { createFileRoute } from "@tanstack/react-router";

import { AppShell } from "@/components/layout/AppShell";
import { HeroSection } from "@/components/home/HeroSection";
import { VisionMissionValues } from "@/components/home/VisionMissionValues";
import { StrategicPaths } from "@/components/home/StrategicPaths";
import { StrategicPriorities } from "@/components/home/StrategicPriorities";
import { OperationalSummary } from "@/components/home/OperationalSummary";
import { ContributionToImpact37 } from "@/components/home/ContributionToImpact37";
import { QuickActions } from "@/components/home/QuickActions";

const title = "منظومة أثر 37 لإدارة الاستراتيجية | الكشافة التونسية";
const description =
  "منظومة أثر 37 لإدارة الاستراتيجية: المسارات الأربعة والأولويات الثمانية ومتابعة الأنشطة نحو حركة شبابية ملهمة ومؤثرة.";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title },
      { name: "description", content: description },
      { property: "og:title", content: title },
      { property: "og:description", content: description },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: Index,
});

function Index() {
  return (
    <AppShell>
      <HeroSection />
      <VisionMissionValues />
      <StrategicPaths />
      <StrategicPriorities />
      <OperationalSummary />
      <div className="grid gap-4 lg:grid-cols-2">
        <ContributionToImpact37 />
        <QuickActions />
      </div>
    </AppShell>
  );
}
