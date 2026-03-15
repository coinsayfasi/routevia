import { StatsCards } from "@/components/dashboard/stats-cards";
import { ModerationQueueTable } from "@/components/moderation/moderation-queue-table";
import { getDashboardStats, listModerationQueue } from "@/lib/data/moderation";

export default async function DashboardPage() {
  const [stats, recentQueue] = await Promise.all([
    getDashboardStats(),
    listModerationQueue({ status: "pending", limit: 12 }),
  ]);

  return (
    <div className="space-y-6">
      <section className="space-y-2">
        <p className="text-sm uppercase tracking-[0.18em] text-slate-500">
          Moderation Dashboard
        </p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
          Bekleyen içerik ve günlük operasyon özeti
        </h2>
      </section>

      <StatsCards stats={stats} />

      <section className="space-y-3">
        <div>
          <h3 className="text-lg font-semibold text-slate-900">Son bekleyen kayıtlar</h3>
          <p className="text-sm text-slate-500">
            Queue server-side sıralanır; client tarafında büyük tablo işlenmez.
          </p>
        </div>
        <ModerationQueueTable rows={recentQueue} />
      </section>
    </div>
  );
}
