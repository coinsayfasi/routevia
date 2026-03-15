import Link from "next/link";
import { requireAdmin } from "@/lib/auth";

const nav = [
  { href: "/", label: "Dashboard" },
  { href: "/moderation", label: "Moderation Queue" },
  { href: "/places", label: "Places" },
  { href: "/stories", label: "Stories" },
  { href: "/images", label: "Images" },
  { href: "/cities", label: "Cities" },
  { href: "/categories", label: "Categories" },
  { href: "/tags", label: "Tags" },
  { href: "/editorial", label: "Editorial" },
];

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { profile } = await requireAdmin();

  return (
    <div className="mx-auto flex min-h-screen max-w-[1600px] gap-6 px-4 py-6 lg:px-6">
      <aside className="panel hidden w-72 rounded-3xl p-5 lg:block">
        <p className="text-xs uppercase tracking-[0.24em] text-slate-500">
          Routevia
        </p>
        <h1 className="mt-3 text-2xl font-semibold tracking-tight">Admin</h1>
        <p className="mt-2 text-sm text-slate-500">{profile.display_name || "Admin"}</p>
        <nav className="mt-8 space-y-1">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="block rounded-2xl px-3 py-2 text-sm text-slate-700 transition hover:bg-teal-50 hover:text-teal-800"
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </aside>
      <main className="min-w-0 flex-1">{children}</main>
    </div>
  );
}
