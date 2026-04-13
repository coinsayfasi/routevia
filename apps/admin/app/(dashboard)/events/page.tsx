import { createEventAction } from "./actions";
import { createSupabaseAdminClient } from "@/lib/supabase/server";

interface Province {
  id: string;
  name: string;
}

interface EventRow {
  id: string;
  province_name: string;
  district: string | null;
  name: string;
  category: string;
  month_start: number;
  month_end: number;
  is_active: boolean;
}

async function listProvinces(): Promise<Province[]> {
  const supabase = await createSupabaseAdminClient();
  const { data, error } = await supabase
    .from("provinces")
    .select("id,name")
    .order("name", { ascending: true });
  if (error) throw error;
  return (data ?? []) as Province[];
}

async function listEvents(): Promise<EventRow[]> {
  const supabase = await createSupabaseAdminClient();
  const { data, error } = await supabase
    .from("events")
    .select("id,province_name,district,name,category,month_start,month_end,is_active")
    .order("province_name", { ascending: true })
    .order("month_start", { ascending: true })
    .limit(200);
  if (error) throw error;
  return (data ?? []) as EventRow[];
}

const months = [
  "",
  "Ocak",
  "Şubat",
  "Mart",
  "Nisan",
  "Mayıs",
  "Haziran",
  "Temmuz",
  "Ağustos",
  "Eylül",
  "Ekim",
  "Kasım",
  "Aralık",
];

export default async function EventsPage({
  searchParams,
}: {
  searchParams: Promise<{ created?: string; error?: string }>;
}) {
  const [{ created, error }, provinces, events] = await Promise.all([
    searchParams,
    listProvinces(),
    listEvents(),
  ]);

  return (
    <div className="space-y-6">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Events</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">
          Etkinlik Yönetimi
        </h2>
        <p className="text-sm text-slate-500">
          Festival ve yıllık tekrar eden etkinlikleri buradan ekleyebilirsin.
        </p>
      </section>

      <section className="panel rounded-3xl p-6 shadow-sm">
        <h3 className="text-lg font-semibold text-slate-900">Yeni Etkinlik Ekle</h3>
        <p className="mt-1 text-sm text-slate-500">
          Sadece yıllık tekrar eden ve editoryal olarak doğruladığın etkinlikleri ekle.
        </p>

        {created ? (
          <div className="mt-4 rounded-2xl bg-teal-50 px-4 py-3 text-sm font-medium text-teal-800">
            Etkinlik kaydedildi.
          </div>
        ) : null}
        {error ? (
          <div className="mt-4 rounded-2xl bg-rose-50 px-4 py-3 text-sm font-medium text-rose-700">
            {decodeURIComponent(error)}
          </div>
        ) : null}

        <form action={createEventAction} className="mt-5 grid gap-4 md:grid-cols-2">
          <label className="grid gap-2 text-sm font-medium text-slate-700">
            İl
            <select
              name="province_id"
              required
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            >
              <option value="">İl seç</option>
              {provinces.map((province) => (
                <option key={province.id} value={province.id}>
                  {province.name}
                </option>
              ))}
            </select>
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            İlçe
            <input
              name="district"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
              placeholder="Örn. Selçuk"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700 md:col-span-2">
            Etkinlik adı
            <input
              name="name"
              required
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
              placeholder="Kırkpınar Yağlı Güreşleri"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Slug
            <input
              name="slug"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
              placeholder="bos birakirsan otomatik uretilir"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Kategori
            <select
              name="category"
              defaultValue="festival"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            >
              {["festival", "müzik", "kültür", "yemek", "spor", "sanat", "doğa", "geleneksel"].map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Başlangıç ayı
            <input
              name="month_start"
              type="number"
              min="1"
              max="12"
              required
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Bitiş ayı
            <input
              name="month_end"
              type="number"
              min="1"
              max="12"
              required
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700 md:col-span-2">
            Açıklama
            <textarea
              name="description"
              rows={4}
              className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-900"
              placeholder="Kısa editoryal açıklama"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700 md:col-span-2">
            Etiketler
            <input
              name="tags"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
              placeholder="unesco, geleneksel, halk-oyunlari"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Latitude
            <input
              name="lat"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700">
            Longitude
            <input
              name="lng"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700 md:col-span-2">
            Image URL
            <input
              name="image_url"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <label className="grid gap-2 text-sm font-medium text-slate-700 md:col-span-2">
            Source URL
            <input
              name="source_url"
              className="rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm text-slate-900"
            />
          </label>

          <div className="md:col-span-2">
            <button
              type="submit"
              className="rounded-xl bg-slate-900 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-700"
            >
              Etkinliği Kaydet
            </button>
          </div>
        </form>
      </section>

      <section className="panel overflow-hidden rounded-3xl shadow-sm">
        <div className="border-b border-slate-100 px-6 py-4">
          <h3 className="text-lg font-semibold text-slate-900">Mevcut Etkinlikler</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 text-left text-xs uppercase tracking-wider text-slate-500">
                <th className="px-5 py-3 font-medium">İl</th>
                <th className="px-5 py-3 font-medium">Etkinlik</th>
                <th className="px-5 py-3 font-medium">Kategori</th>
                <th className="px-5 py-3 font-medium">Ay</th>
                <th className="px-5 py-3 font-medium">Durum</th>
              </tr>
            </thead>
            <tbody>
              {events.map((event) => (
                <tr key={event.id} className="border-b border-slate-50 hover:bg-slate-50/60">
                  <td className="px-5 py-3 font-medium text-slate-800">
                    {event.province_name}
                    {event.district ? <span className="text-slate-500"> / {event.district}</span> : null}
                  </td>
                  <td className="px-5 py-3 text-slate-800">{event.name}</td>
                  <td className="px-5 py-3 text-slate-500">{event.category}</td>
                  <td className="px-5 py-3 text-slate-500">
                    {event.month_start === event.month_end
                      ? months[event.month_start]
                      : `${months[event.month_start]} - ${months[event.month_end]}`}
                  </td>
                  <td className="px-5 py-3">
                    <span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${event.is_active ? "bg-teal-50 text-teal-700" : "bg-slate-100 text-slate-500"}`}>
                      {event.is_active ? "active" : "inactive"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
