import { moderateSubmission } from "@/lib/actions/moderation";
import { getModerationDetail } from "@/lib/data/moderation";
import { formatDate } from "@/lib/utils";

type Props = {
  params: Promise<{
    submissionType: "place_submission" | "story_submission" | "photo_submission";
    submissionId: string;
  }>;
};

export default async function ModerationDetailPage({ params }: Props) {
  const { submissionType, submissionId } = await params;
  const { queue, detail } = await getModerationDetail(submissionType, submissionId);

  async function submitAction(formData: FormData) {
    "use server";
    await moderateSubmission({
      submissionType,
      submissionId,
      decision: formData.get("decision"),
      adminNote: formData.get("adminNote"),
      rejectionReason: formData.get("rejectionReason"),
      publish: formData.get("publish") === "on",
      setCover: formData.get("setCover") === "on",
    });
  }

  return (
    <div className="grid gap-6 xl:grid-cols-[1.4fr_0.8fr]">
      <section className="panel rounded-3xl p-6 shadow-sm">
        <div className="space-y-2">
          <p className="text-sm uppercase tracking-[0.18em] text-slate-500">
            {submissionType}
          </p>
          <h2 className="text-2xl font-semibold tracking-tight text-slate-950">
            {queue.searchable_title || "İçerik detayı"}
          </h2>
          <p className="text-sm text-slate-500">
            Gönderen: {queue.submitter_name || "-"} · Yer: {queue.place_name || "-"}
          </p>
        </div>

        <dl className="mt-6 grid gap-4 md:grid-cols-2">
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-slate-500">Durum</dt>
            <dd className="mt-1 text-sm text-slate-900">{queue.status}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-slate-500">Gönderim</dt>
            <dd className="mt-1 text-sm text-slate-900">{formatDate(queue.submitted_at)}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-slate-500">Bucket</dt>
            <dd className="mt-1 text-sm text-slate-900">{queue.bucket || "-"}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-slate-500">Object Path</dt>
            <dd className="mt-1 break-all text-sm text-slate-900">{queue.object_path || "-"}</dd>
          </div>
        </dl>

        <div className="mt-6 rounded-2xl border border-slate-200 bg-white/60 p-4">
          <pre className="whitespace-pre-wrap break-words text-sm text-slate-700">
            {JSON.stringify(detail, null, 2)}
          </pre>
        </div>
      </section>

      <section className="panel rounded-3xl p-6 shadow-sm">
        <h3 className="text-lg font-semibold text-slate-900">Moderasyon aksiyonu</h3>
        <form action={submitAction} className="mt-5 space-y-4">
          <div className="grid gap-2">
            <label className="text-sm font-medium text-slate-700" htmlFor="decision">
              Karar
            </label>
            <select
              id="decision"
              name="decision"
              defaultValue={queue.status}
              className="rounded-2xl border border-slate-200 bg-white px-3 py-2 text-sm"
            >
              <option value="pending">pending</option>
              <option value="approved">approved</option>
              <option value="rejected">rejected</option>
              <option value="needs_edit">needs_edit</option>
            </select>
          </div>

          <div className="grid gap-2">
            <label className="text-sm font-medium text-slate-700" htmlFor="adminNote">
              Admin notu
            </label>
            <textarea
              id="adminNote"
              name="adminNote"
              defaultValue={queue.admin_note || ""}
              className="min-h-28 rounded-2xl border border-slate-200 bg-white px-3 py-2 text-sm"
            />
          </div>

          <div className="grid gap-2">
            <label className="text-sm font-medium text-slate-700" htmlFor="rejectionReason">
              Red nedeni
            </label>
            <textarea
              id="rejectionReason"
              name="rejectionReason"
              defaultValue={queue.rejection_reason || ""}
              className="min-h-24 rounded-2xl border border-slate-200 bg-white px-3 py-2 text-sm"
            />
          </div>

          <label className="flex items-center gap-3 text-sm text-slate-700">
            <input type="checkbox" name="publish" defaultChecked />
            Onayda public tabloya publish et
          </label>

          <label className="flex items-center gap-3 text-sm text-slate-700">
            <input type="checkbox" name="setCover" />
            Fotoğrafsa cover olarak ata
          </label>

          <button
            type="submit"
            className="w-full rounded-2xl bg-teal-700 px-4 py-3 text-sm font-semibold text-white transition hover:bg-teal-800"
          >
            Kaydet
          </button>
        </form>
      </section>
    </div>
  );
}
