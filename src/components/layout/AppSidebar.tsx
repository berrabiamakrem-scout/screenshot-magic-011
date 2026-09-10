import { Link } from "@tanstack/react-router";
import {
  Home,
  Database,
  Search,
  Target,
  CalendarDays,
  BarChart3,
  Landmark,
  LayoutDashboard,
  FileText,
  Settings,
  type LucideIcon,
} from "lucide-react";

import impactLogo from "@/assets/impact37-logo.jpg.asset.json";
import { identity } from "@/data/impact37";

type NavItem = { label: string; icon: LucideIcon; to?: string };

export const navItems: NavItem[] = [
  { label: "الرئيسية", icon: Home, to: "/" },
  { label: "البيانات", icon: Database },
  { label: "التشخيص", icon: Search },
  { label: "الاستراتيجية", icon: Target },
  { label: "الخطط والأنشطة", icon: CalendarDays },
  { label: "المتابعة", icon: BarChart3 },
  { label: "الحوكمة والهياكل", icon: Landmark },
  { label: "لوحة القيادة", icon: LayoutDashboard },
  { label: "التقارير", icon: FileText },
  { label: "الإدارة", icon: Settings },
];

export function SidebarContent({ onNavigate }: { onNavigate?: () => void }) {
  return (
    <div className="flex h-full flex-col gap-3 bg-linear-to-b from-sidebar to-sidebar-accent/60 text-sidebar-foreground">
      <div className="px-5 pt-4">
        <div className="mx-auto w-fit rounded-xl bg-white px-3 py-2 shadow-card">
          <img
            src={impactLogo.url}
            alt="شعار أثر 37 – IMPACT 37"
            className="mx-auto h-16 w-auto object-contain"
          />
        </div>
      </div>

      <nav className="flex-1 space-y-0.5 px-3" aria-label="القائمة الرئيسية">
        {navItems.map((item, index) => {
          const Icon = item.icon;
          const isActive = index === 0;
          const className = `flex items-center gap-2.5 rounded-lg px-3 py-1.5 text-[0.85rem] font-medium transition-colors ${
            isActive
              ? "bg-sidebar-active text-white shadow-card ring-1 ring-teal/40"
              : "text-sidebar-foreground/75 hover:bg-sidebar-accent/70 hover:text-white"
          }`;

          return item.to ? (
            <Link key={item.label} to={item.to} className={className} onClick={onNavigate}>
              <Icon className="size-[1.15rem] shrink-0" aria-hidden />
              <span>{item.label}</span>
            </Link>
          ) : (
            <button key={item.label} type="button" className={`w-full ${className}`} onClick={onNavigate}>
              <Icon className="size-[1.15rem] shrink-0" aria-hidden />
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>

      <div className="border-t border-sidebar-border px-5 py-3">
        <p className="text-[0.75rem] text-sidebar-foreground/60">معاً...</p>
        <p className="font-display text-base font-bold text-white">نصنع أثراً يدوم</p>
        <p className="mt-0.5 text-[0.7rem] text-teal-soft">{identity.tagline}</p>
      </div>
    </div>
  );
}

export function AppSidebar() {
  return (
    <div className="hidden lg:block">
      {/* Spacer that reserves space on the right for the sidebar */}
      <div className="w-64 shrink-0 bg-transparent" aria-hidden />

      {/* Sidebar panel, explicitly anchored to the right edge */}
      <aside className="fixed inset-y-0 right-0 z-20 w-64 overflow-y-auto border-e border-sidebar-border bg-sidebar">
        <SidebarContent />
      </aside>
    </div>
  );
}
