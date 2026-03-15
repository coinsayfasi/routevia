import type { DashboardStats } from "@/lib/types/moderation";

export function StatsCards({ stats }: { stats: DashboardStats }) {
  const items = [
    { label: "Bekleyen yer", value: stats.pendingPlaces },
    { label: "Bekleyen hikaye", value: stats.pendingStories },
    { label: "Bekleyen foto", value: stats.pendingPhotos },
    { label: "Bugün onaylanan", value: stats.approvedToday },
    { label: "Bugün reddedilen", value: stats.rejectedToday },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
      {items.map((item) => (
        <div key={item.label} className="panel rounded-2xl p-5 shadow-sm">
          <p className="text-sm text-slate-500">{item.label}</p>
          <p className="mt-3 text-3xl font-semibold tracking-tight text-slate-900">
            {item.value}
          </p>
        </div>
      ))}
    </div>
  );
}
