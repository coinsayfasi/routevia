import Link from "next/link";
import { formatDate } from "@/lib/utils";
import type { ModerationQueueRow } from "@/lib/types/moderation";

const statusTone: Record<string, string> = {
  pending: "bg-amber-100 text-amber-800",
  approved: "bg-emerald-100 text-emerald-800",
  rejected: "bg-rose-100 text-rose-800",
  needs_edit: "bg-sky-100 text-sky-800",
};

export function ModerationQueueTable({ rows }: { rows: ModerationQueueRow[] }) {
  return (
    <div className="panel overflow-hidden rounded-2xl shadow-sm">
      <table className="min-w-full divide-y divide-slate-200 text-sm">
        <thead className="bg-white/60">
          <tr className="text-left text-slate-500">
            <th className="px-4 py-3 font-medium">İçerik</th>
            <th className="px-4 py-3 font-medium">Tür</th>
            <th className="px-4 py-3 font-medium">Durum</th>
            <th className="px-4 py-3 font-medium">Yer</th>
            <th className="px-4 py-3 font-medium">Gönderen</th>
            <th className="px-4 py-3 font-medium">Tarih</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100">
          {rows.map((row) => (
            <tr key={row.id} className="bg-white/30 transition hover:bg-white/70">
              <td className="px-4 py-4">
                <Link
                  href={`/moderation/${row.submission_type}/${row.submission_id}`}
                  className="font-medium text-slate-900 hover:text-teal-700"
                >
                  {row.searchable_title || "İsimsiz kayıt"}
                </Link>
                <p className="mt-1 max-w-xl truncate text-slate-500">
                  {row.searchable_excerpt || "-"}
                </p>
              </td>
              <td className="px-4 py-4 capitalize text-slate-600">
                {row.submission_type.replace("_", " ")}
              </td>
              <td className="px-4 py-4">
                <span
                  className={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${statusTone[row.status]}`}
                >
                  {row.status}
                </span>
              </td>
              <td className="px-4 py-4 text-slate-600">{row.place_name || "-"}</td>
              <td className="px-4 py-4 text-slate-600">{row.submitter_name || "-"}</td>
              <td className="px-4 py-4 text-slate-600">{formatDate(row.submitted_at)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
