import { useState } from "react";
import { Bell, Menu, Search, Settings, X, ChevronDown } from "lucide-react";

import scoutsLogo from "@/assets/scouts-tunisia.png.asset.json";
import { identity } from "@/data/impact37";
import { SidebarContent } from "./AppSidebar";

export function AppHeader() {
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  return (
    <>
      <header className="sticky top-0 z-30 border-b border-border bg-surface/95 backdrop-blur">
        <div className="flex items-center gap-3 px-4 py-2 sm:px-5">
          <button
            type="button"
            onClick={() => setMobileNavOpen(true)}
            className="rounded-lg border border-border p-2 text-navy lg:hidden"
            aria-label="فتح القائمة"
          >
            <Menu className="size-5" aria-hidden />
          </button>

          <div className="flex items-center gap-3">
            <img
              src={scoutsLogo.url}
              alt="شعار الكشافة التونسية"
              className="h-9 w-9 shrink-0 object-contain"
            />
            <div className="leading-tight">
              <p className="font-display text-sm font-bold text-navy sm:text-base">
                {identity.organization}
              </p>
              <p className="hidden text-[0.7rem] text-muted-foreground sm:block">
                {identity.committee}
              </p>
            </div>
          </div>

          <div className="ms-auto flex items-center gap-2 sm:gap-3">
            <div className="relative hidden md:block">
              <Search
                className="pointer-events-none absolute end-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground"
                aria-hidden
              />
              <input
                type="search"
                placeholder="البحث في المنظومة..."
                aria-label="البحث في المنظومة"
                className="w-48 rounded-lg border border-border bg-background py-1.5 pe-9 ps-3 text-[0.8rem] text-navy outline-none transition-colors placeholder:text-muted-foreground focus:border-teal focus:ring-2 focus:ring-teal/20 lg:w-64"
              />
            </div>

            <button
              type="button"
              className="rounded-lg border border-border p-2 text-navy/70 transition-colors hover:text-navy"
              aria-label="الإعدادات"
            >
              <Settings className="size-[1.15rem]" aria-hidden />
            </button>

            <button
              type="button"
              className="relative rounded-lg border border-border p-2 text-navy/70 transition-colors hover:text-navy"
              aria-label="الإشعارات"
            >
              <Bell className="size-[1.15rem]" aria-hidden />
              <span className="absolute -top-1.5 -start-1.5 flex size-5 items-center justify-center rounded-full bg-scarlet text-[0.65rem] font-bold text-primary-foreground">
                3
              </span>
            </button>

            <button
              type="button"
              className="flex items-center gap-2 rounded-lg border border-border px-2 py-1 text-start transition-colors hover:bg-secondary"
            >
              <span className="flex size-8 items-center justify-center rounded-full bg-navy-soft font-display text-xs font-bold text-navy">
                م ع
              </span>
              <span className="hidden leading-tight sm:block">
                <span className="block text-[0.8rem] font-semibold text-navy">محمد العباري</span>
                <span className="block text-[0.68rem] text-muted-foreground">قائد جهة تونس</span>
              </span>
              <ChevronDown className="hidden size-4 text-muted-foreground sm:block" aria-hidden />
            </button>
          </div>
        </div>
      </header>

      {mobileNavOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <button
            type="button"
            aria-label="إغلاق القائمة"
            className="absolute inset-0 bg-navy/40"
            onClick={() => setMobileNavOpen(false)}
          />
          <div className="absolute inset-y-0 start-0 w-72 max-w-[85vw] overflow-y-auto bg-sidebar shadow-raised">
            <div className="flex justify-start p-3">
              <button
                type="button"
                onClick={() => setMobileNavOpen(false)}
                className="rounded-lg border border-border p-2 text-navy"
                aria-label="إغلاق القائمة"
              >
                <X className="size-5" aria-hidden />
              </button>
            </div>
            <SidebarContent onNavigate={() => setMobileNavOpen(false)} />
          </div>
        </div>
      )}
    </>
  );
}
