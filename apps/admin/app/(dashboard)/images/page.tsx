import { createSupabaseAdminClient } from "@/lib/supabase/server";
import { moderateSubmission } from "@/lib/actions/moderation";

interface PhotoSubmission {
  id: string;
  place_id: string | null;
  bucket: string | null;
  object_path: string | null;
  caption: string | null;
  status: string | null;
  submitted_at: string | null;
}

const SUPABASE_URL =
  process.env.NEXT_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL ?? "";

function storageUrl(bucket: string | null, objectPath: string | null): string | null {
  if (!bucket || !objectPath) return null;
  return `${SUPABASE_URL}/storage/v1/object/public/${bucket}/${objectPath}`;
}

async function listPhotoSubmissions(status: string): Promise<PhotoSubmission[]> {
  const supabase = await createSupabaseAdminClient();
  let query = supabase
    .from("user_photo_submissions")
    .select("id,place_id,bucket,object_path,caption,status,submitted_at")
    .order("submitted_at", { ascending: false })
    .limit(60);
  if (status !== "all") {
    query = query.eq("status", status);
  }
  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as PhotoSubmission[];
}

export default async function ImagesPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string>>;
}) {
  const params = await searchParams;
  const status = params.status ?? "pending";
  const photos = await listPhotoSubmissions(status);

  return (
    <div className="space-y-6">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Images</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">Fotoğraf Galerisi</h2>
        <p className="text-sm text-slate-500">{photos.length} fotoğraf gösteriliyor</p>
      </section>

      {/* Filter tabs */}
      <div className="flex gap-2">
        {["pending", "approved", "rejected", "all"].map((s) => (
          <a
            key={s}
            href={`/images?status=${s}`}
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

      {/* Grid */}
      {photos.length === 0 ? (
        <div className="panel rounded-3xl shadow-sm p-12 text-center text-slate-400">
          Bu filtre için fotoğraf yok.
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {photos.map((photo) => {
            const imgUrl = storageUrl(photo.bucket, photo.object_path);
            return (
              <div key={photo.id} className="panel rounded-2xl shadow-sm overflow-hidden flex flex-col">
                {imgUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={imgUrl}
                    alt={photo.caption ?? ""}
                    className="w-full h-40 object-cover bg-slate-100"
                    loading="lazy"
                  />
                ) : (
                  <div className="w-full h-40 bg-slate-100 flex items-center justify-center text-slate-400 text-sm">
                    Görsel yok
                  </div>
                )}
                <div className="p-3 space-y-2 flex-1 flex flex-col justify-between">
                  <div className="flex items-center justify-between">
                    <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${
                      photo.status === "approved" ? "bg-green-100 text-green-700"
                      : photo.status === "rejected" ? "bg-red-100 text-red-700"
                      : "bg-amber-100 text-amber-700"
                    }`}>
                      {photo.status === "approved" ? "Onaylı" : photo.status === "rejected" ? "Reddedildi" : "Bekliyor"}
                    </span>
                    <span className="text-xs text-slate-400">
                      {photo.submitted_at ? new Date(photo.submitted_at).toLocaleDateString("tr-TR") : "—"}
                    </span>
                  </div>
                  {photo.caption && (
                    <p className="text-xs text-slate-500 truncate">{photo.caption}</p>
                  )}
                  {photo.status === "pending" && (
                    <div className="flex gap-2 pt-1">
                      <form
                        action={moderateSubmission.bind(null, {
                          submissionType: "photo_submission",
                          submissionId: photo.id,
                          decision: "approved",
                          publish: true,
                          setCover: false,
                        })}
                        className="flex-1"
                      >
                        <button
                          type="submit"
                          className="w-full rounded-lg bg-green-600 py-1 text-xs font-semibold text-white hover:bg-green-700 transition"
                        >
                          Onayla
                        </button>
                      </form>
                      <form
                        action={moderateSubmission.bind(null, {
                          submissionType: "photo_submission",
                          submissionId: photo.id,
                          decision: "rejected",
                          publish: false,
                          setCover: false,
                        })}
                        className="flex-1"
                      >
                        <button
                          type="submit"
                          className="w-full rounded-lg bg-red-100 py-1 text-xs font-semibold text-red-700 hover:bg-red-200 transition"
                        >
                          Reddet
                        </button>
                      </form>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
