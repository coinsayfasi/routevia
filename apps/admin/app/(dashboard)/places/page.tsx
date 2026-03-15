import { listPlaces } from "@/lib/data/places";
import { togglePublished, toggleFeatured } from "@/lib/actions/places";

const CATEGORIES = [
  "all","museum","historical","nature","beach","viewpoint",
  "food","cafe","lodging","activity","market","tour","waterfall","canyon",
];

export default async function PlacesPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string>>;
}) {
  const params = await searchParams;
  const search = params.search ?? "";
  const category = params.category ?? "all";
  const published = params.published ?? "all";
  const page = parseInt(params.page ?? "1", 10);

  const { rows, total } = await listPlaces({ search, category, published, page });
  const totalPages = Math.ceil(total / 25);

  return (
    <div className="space-y-6">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Places</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
          Yer Yönetimi
        </h2>
        <p className="text-sm text-slate-500">
          {total.toLocaleString("tr-TR")} yer · Sayfa {page}/{totalPages || 1}
        </p>
      </section>

      {/* Filters */}
      <form method="GET" className="panel rounded-3xl p-4 flex flex-wrap gap-3 items-end shadow-sm">
        <div className="flex flex-col gap-1">
          <label className="text-xs text-slate-500 font-medium">Ara</label>
          <input
            name="search"
            defaultValue={search}
            placeholder="Yer adı..."
            className="rounded-xl border border-slate-200 px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
          />
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs text-slate-500 font-medium">Kategori</label>
          <select
            name="category"
            defaultValue={category}
            className="rounded-xl border border-slate-200 px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
          >
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>{c === "all" ? "Tümü" : c}</option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <label className="text-xs text-slate-500 font-medium">Yayın Durumu</label>
          <select
            name="published"
            defaultValue={published}
            className="rounded-xl border border-slate-200 px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
          >
            <option value="all">Tümü</option>
            <option value="true">Yayında</option>
            <option value="false">Yayında Değil</option>
          </select>
        </div>
        <button
          type="submit"
          className="rounded-xl bg-teal-600 px-4 py-1.5 text-sm font-semibold text-white hover:bg-teal-700 transition"
        >
          Filtrele
        </button>
      </form>

      {/* Table */}
      <div className="panel rounded-3xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 text-left text-xs uppercase tracking-wider text-slate-500">
                <th className="px-5 py-3 font-medium">Ad</th>
                <th className="px-5 py-3 font-medium">Kategori</th>
                <th className="px-5 py-3 font-medium">Şehir</th>
                <th className="px-5 py-3 font-medium">Doğrulandı</th>
                <th className="px-5 py-3 font-medium">Yayın</th>
                <th className="px-5 py-3 font-medium">Öne Çıkan</th>
              </tr>
            </thead>
            <tbody>
              {rows.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-5 py-8 text-center text-slate-400">
                    Sonuç yok
                  </td>
                </tr>
              )}
              {rows.map((place) => (
                <tr key={place.id} className="border-b border-slate-50 hover:bg-slate-50/60 transition">
                  <td className="px-5 py-3 font-medium text-slate-800 max-w-[220px] truncate">
                    {place.name}
                  </td>
                  <td className="px-5 py-3 text-slate-500">{place.category}</td>
                  <td className="px-5 py-3 text-slate-500 max-w-[140px] truncate">
                    {place.city ?? "—"}
                  </td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${place.provenance_verified ? "bg-green-100 text-green-700" : "bg-slate-100 text-slate-500"}`}>
                      {place.provenance_verified ? "Evet" : "Hayır"}
                    </span>
                  </td>
                  <td className="px-5 py-3">
                    <form action={togglePublished.bind(null, place.id, place.is_published ?? false)}>
                      <button
                        type="submit"
                        className={`rounded-full px-3 py-0.5 text-xs font-semibold transition ${
                          place.is_published
                            ? "bg-green-100 text-green-700 hover:bg-red-100 hover:text-red-700"
                            : "bg-slate-100 text-slate-500 hover:bg-green-100 hover:text-green-700"
                        }`}
                      >
                        {place.is_published ? "Yayında" : "Yayınla"}
                      </button>
                    </form>
                  </td>
                  <td className="px-5 py-3">
                    <form action={toggleFeatured.bind(null, place.id, place.is_featured ?? false)}>
                      <button
                        type="submit"
                        className={`rounded-full px-3 py-0.5 text-xs font-semibold transition ${
                          place.is_featured
                            ? "bg-amber-100 text-amber-700 hover:bg-slate-100 hover:text-slate-500"
                            : "bg-slate-100 text-slate-500 hover:bg-amber-100 hover:text-amber-700"
                        }`}
                      >
                        {place.is_featured ? "★ Öne Çıkan" : "Öne Çıkar"}
                      </button>
                    </form>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-5 py-4 border-t border-slate-100">
            <p className="text-sm text-slate-500">
              {((page - 1) * 25) + 1}–{Math.min(page * 25, total)} / {total}
            </p>
            <div className="flex gap-2">
              {page > 1 && (
                <a
                  href={`/places?search=${encodeURIComponent(search)}&category=${category}&published=${published}&page=${page - 1}`}
                  className="rounded-xl border border-slate-200 px-3 py-1.5 text-sm hover:bg-slate-50 transition"
                >
                  ← Önceki
                </a>
              )}
              {page < totalPages && (
                <a
                  href={`/places?search=${encodeURIComponent(search)}&category=${category}&published=${published}&page=${page + 1}`}
                  className="rounded-xl bg-teal-600 px-3 py-1.5 text-sm font-semibold text-white hover:bg-teal-700 transition"
                >
                  Sonraki →
                </a>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
