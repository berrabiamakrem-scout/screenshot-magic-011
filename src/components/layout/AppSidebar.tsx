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
    <div className="flex h-full flex-col gap-6 bg-sidebar">
      <div className="px-5 pt-6">
        <img
          src={impactLogo.url}
          alt="شعار أثر 37 – IMPACT 37"
          className="mx-auto h-24 w-auto object-contain"
        />
      </div>

      <nav className="flex-1 space-y-1 px-3" aria-label="القائمة الرئيسية">
        {navItems.map((item, index) => {
          const Icon = item.icon;
          const isActive = index === 0;
          const className = `flex items-center gap-3 rounded-lg px-3 py-2.5 text-[0.95rem] font-medium transition-colors ${
            isActive
              ? "bg-navy text-primary-foreground shadow-card"
              : "text-navy/80 hover:bg-sidebar-accent hover:text-navy"
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

      <div className="border-t border-border px-5 py-5">
        <p className="text-sm text-muted-foreground">معاً...</p>
        <p className="font-display text-lg font-bold text-navy">نصنع أثراً يدوم</p>
        <p className="mt-1 text-xs text-teal">{identity.tagline}</p>
      </div>
    </div>
  );
}

export function AppSidebar() {
  return (
    <aside className="hidden w-64 shrink-0 border-s border-border bg-sidebar lg:block">
      <div className="sticky top-0 h-screen overflow-y-auto">
        <SidebarContent />
      </div>
    </aside>
  );
}
