import { ModerationQueueTable } from "@/components/moderation/moderation-queue-table";
import { listModerationQueue } from "@/lib/data/moderation";

type Props = {
  searchParams?: Promise<{
    status?: string;
    type?: string;
    q?: string;
  }>;
};

export default async function ModerationPage({ searchParams }: Props) {
  const params = (await searchParams) ?? {};
  const rows = await listModerationQueue({
    status:
      params.status === "approved" ||
      params.status === "rejected" ||
      params.status === "needs_edit" ||
      params.status === "pending"
        ? params.status
        : "pending",
    submissionType:
      params.type === "place_submission" ||
      params.type === "story_submission" ||
      params.type === "photo_submission"
        ? params.type
        : "all",
    search: params.q,
    limit: 50,
  });

  return (
    <div className="space-y-5">
      <div>
        <p className="text-sm uppercase tracking-[0.18em] text-slate-500">
          Moderation Queue
        </p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
          Tek merkezden tüm kullanıcı gönderileri
        </h2>
      </div>
      <ModerationQueueTable rows={rows} />
    </div>
  );
}
