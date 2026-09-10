import type { ReactNode } from "react";

import { AppHeader } from "./AppHeader";
import { AppSidebar } from "./AppSidebar";

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen bg-background">
      <AppSidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <AppHeader />
        <main className="mx-auto w-full max-w-[1500px] flex-1 space-y-4 px-3 py-4 sm:px-5">
          {children}
        </main>
      </div>
    </div>
  );
}

export function SectionHeader({
  title,
  action,
}: {
  title: string;
  action?: { label: string; onClick?: () => void };
}) {
  return (
    <div className="mb-2 flex items-center justify-between gap-4">
      <h2 className="section-title">{title}</h2>
      {action && (
        <button
          type="button"
          onClick={action.onClick}
          className="text-sm font-medium text-teal transition-colors hover:text-navy"
        >
          {action.label}
        </button>
      )}
    </div>
  );
}
