import { listFeaturedPlaces } from "@/lib/data/places";
import { toggleFeatured } from "@/lib/actions/places";

export default async function EditorialPage() {
  const featured = await listFeaturedPlaces();

  return (
    <div className="space-y-8">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Editorial</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
          Editoryal Yönetim
        </h2>
        <p className="text-sm text-slate-500">
          Öne çıkan yerler ve haftalık rotalar burada yönetilir.
        </p>
      </section>

      <section className="space-y-3">
        <div>
          <h3 className="text-lg font-semibold text-slate-900">Öne Çıkan Yerler</h3>
          <p className="text-sm text-slate-500">
            {featured.length} yer öne çıkarılmış · Kaldırmak için butona bas.
          </p>
        </div>
        <div className="panel rounded-3xl shadow-sm overflow-hidden">
          {featured.length === 0 ? (
            <div className="px-5 py-12 text-center text-slate-400">
              Henüz öne çıkan yer yok. Places sayfasından ekleyebilirsin.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-slate-100 text-left text-xs uppercase tracking-wider text-slate-500">
                    <th className="px-5 py-3 font-medium">Ad</th>
                    <th className="px-5 py-3 font-medium">Kategori</th>
                    <th className="px-5 py-3 font-medium">Şehir</th>
                    <th className="px-5 py-3 font-medium">Yayın</th>
                    <th className="px-5 py-3 font-medium">İşlem</th>
                  </tr>
                </thead>
                <tbody>
                  {featured.map((place) => (
                    <tr key={place.id} className="border-b border-slate-50 hover:bg-slate-50/60 transition">
                      <td className="px-5 py-3 font-medium text-slate-800 max-w-[200px] truncate">{place.name}</td>
                      <td className="px-5 py-3 text-slate-500">{place.category}</td>
                      <td className="px-5 py-3 text-slate-500">{place.city ?? "—"}</td>
                      <td className="px-5 py-3">
                        <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${place.provenance_verified ? "bg-green-100 text-green-700" : "bg-slate-100 text-slate-500"}`}>
                          {place.provenance_verified ? "Doğrulandı" : "Bekliyor"}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <form action={toggleFeatured.bind(null, place.id, true)}>
                          <button type="submit" className="rounded-full bg-red-50 px-3 py-0.5 text-xs font-semibold text-red-600 hover:bg-red-100 transition">
                            Kaldır
                          </button>
                        </form>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </section>

      <section className="space-y-3">
        <div className="flex items-center gap-3">
          <h3 className="text-lg font-semibold text-slate-900">Haftalık Rotalar</h3>
          <span className="rounded-full bg-amber-100 px-3 py-0.5 text-xs font-semibold text-amber-700">Yakında</span>
        </div>
        <div className="panel rounded-3xl shadow-sm p-8 text-center text-slate-400 space-y-2">
          <p className="text-2xl">🗺️</p>
          <p className="font-medium text-slate-500">Haftalık rota özelliği geliştirme aşamasında</p>
          <p className="text-sm">Editoryal olarak seçilmiş haftanın rotaları burada yönetilecek.</p>
        </div>
      </section>
    </div>
  );
}
