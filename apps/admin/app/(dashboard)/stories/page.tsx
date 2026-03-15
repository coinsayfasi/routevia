import { createSupabaseAdminClient } from "@/lib/supabase/server";
import { moderateSubmission } from "@/lib/actions/moderation";

interface StoryRow {
  id: string;
  title: string | null;
  story_kind: string | null;
  status: string | null;
  created_at: string | null;
  user_id: string | null;
}

async function listStories(status: string): Promise<StoryRow[]> {
  const supabase = await createSupabaseAdminClient();
  let query = supabase
    .from("user_story_submissions")
    .select("id,title,story_kind,status,created_at,user_id")
    .order("created_at", { ascending: false })
    .limit(50);
  if (status !== "all") {
    query = query.eq("status", status);
  }
  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as StoryRow[];
}

const KIND_LABEL: Record<string, string> = {
  story: "Hikaye",
  local_tip: "Lokal İpucu",
  history_note: "Tarihsel Not",
  hidden_feature: "Gizli Özellik",
};

export default async function StoriesPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string>>;
}) {
  const params = await searchParams;
  const status = params.status ?? "pending";
  const stories = await listStories(status);

  return (
    <div className="space-y-6">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Stories</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">Yer Hikayeleri</h2>
        <p className="text-sm text-slate-500">{stories.length} kayıt gösteriliyor</p>
      </section>

      {/* Filter */}
      <div className="flex gap-2">
        {["pending","approved","rejected","all"].map((s) => (
          <a
            key={s}
            href={`/stories?status=${s}`}
            className={`rounded-full px-4 py-1.5 text-sm font-semibold transition ${
              status === s
                ? "bg-teal-600 text-white"
                : "bg-slate-100 text-slate-600 hover:bg-slate-200"
            }`}
          >
            {s === "pending" ? "Bekleyen" : s === "approved" ? "Onaylı" : s === "rejected" ? "Reddedilen" : "Tümü"}
          </a>
        ))}
      </div>

      <div className="panel rounded-3xl shadow-sm overflow-hidden">
        {stories.length === 0 ? (
          <div className="px-5 py-12 text-center text-slate-400">Bu filtre için hikaye yok.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-slate-100 text-left text-xs uppercase tracking-wider text-slate-500">
                  <th className="px-5 py-3 font-medium">Başlık</th>
                  <th className="px-5 py-3 font-medium">Tür</th>
                  <th className="px-5 py-3 font-medium">Durum</th>
                  <th className="px-5 py-3 font-medium">Tarih</th>
                  <th className="px-5 py-3 font-medium">İşlem</th>
                </tr>
              </thead>
              <tbody>
                {stories.map((story) => (
                  <tr key={story.id} className="border-b border-slate-50 hover:bg-slate-50/60 transition">
                    <td className="px-5 py-3 font-medium text-slate-800 max-w-[240px] truncate">
                      {story.title ?? "İsimsiz"}
                    </td>
                    <td className="px-5 py-3 text-slate-500">
                      {KIND_LABEL[story.story_kind ?? ""] ?? story.story_kind ?? "—"}
                    </td>
                    <td className="px-5 py-3">
                      <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                        story.status === "approved" ? "bg-green-100 text-green-700"
                        : story.status === "rejected" ? "bg-red-100 text-red-700"
                        : "bg-amber-100 text-amber-700"
                      }`}>
                        {story.status === "approved" ? "Onaylı" : story.status === "rejected" ? "Reddedildi" : "Bekliyor"}
                      </span>
                    </td>
                    <td className="px-5 py-3 text-slate-400 text-xs">
                      {story.created_at ? new Date(story.created_at).toLocaleDateString("tr-TR") : "—"}
                    </td>
                    <td className="px-5 py-3">
                      {story.status === "pending" && (
                        <div className="flex gap-2">
                          <form action={moderateSubmission.bind(null, {
                            submissionType: "story_submission",
                            submissionId: story.id,
                            decision: "approved",
                            publish: true,
                            setCover: false,
                          })}>
                            <button type="submit" className="rounded-lg bg-green-600 px-3 py-1 text-xs font-semibold text-white hover:bg-green-700 transition">
                              Onayla
                            </button>
                          </form>
                          <form action={moderateSubmission.bind(null, {
                            submissionType: "story_submission",
                            submissionId: story.id,
                            decision: "rejected",
                            publish: false,
                            setCover: false,
                          })}>
                            <button type="submit" className="rounded-lg bg-red-100 px-3 py-1 text-xs font-semibold text-red-700 hover:bg-red-200 transition">
                              Reddet
                            </button>
                          </form>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
