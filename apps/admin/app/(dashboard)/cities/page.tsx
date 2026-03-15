import { createSupabaseAdminClient } from "@/lib/supabase/server";

interface Province {
  id: string;
  name: string;
  slug: string;
}

async function listProvinces(): Promise<Province[]> {
  const supabase = await createSupabaseAdminClient();
  const { data, error } = await supabase
    .from("provinces")
    .select("id,name,slug")
    .order("name", { ascending: true });
  if (error) throw error;
  return (data ?? []) as Province[];
}

async function getPlaceCountPerProvince(): Promise<Record<string, number>> {
  const supabase = await createSupabaseAdminClient();
  const { data } = await supabase
    .from("pois")
    .select("province_id")
    .eq("provenance_verified", true);
  const counts: Record<string, number> = {};
  for (const row of data ?? []) {
    const id = (row as Record<string, unknown>).province_id as string | undefined;
    if (id) counts[id] = (counts[id] ?? 0) + 1;
  }
  return counts;
}

export default async function CitiesPage() {
  const [provinces, placeCounts] = await Promise.all([
    listProvinces(),
    getPlaceCountPerProvince(),
  ]);

  return (
    <div className="space-y-6">
      <section className="space-y-1">
        <p className="text-xs uppercase tracking-[0.18em] text-slate-500">Cities</p>
        <h2 className="text-3xl font-semibold tracking-tight text-slate-950">Şehir / İl Yönetimi</h2>
        <p className="text-sm text-slate-500">{provinces.length} il kayıtlı</p>
      </section>

      <div className="panel rounded-3xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 text-left text-xs uppercase tracking-wider text-slate-500">
                <th className="px-5 py-3 font-medium">Ad</th>
                <th className="px-5 py-3 font-medium">Slug</th>
                <th className="px-5 py-3 font-medium">Doğrulanmış Yer</th>
              </tr>
            </thead>
            <tbody>
              {provinces.map((p) => (
                <tr key={p.id} className="border-b border-slate-50 hover:bg-slate-50/60 transition">
                  <td className="px-5 py-3 font-semibold text-slate-800">{p.name}</td>
                  <td className="px-5 py-3 text-slate-500 font-mono text-xs">{p.slug}</td>
                  <td className="px-5 py-3">
                    <span className="rounded-full bg-teal-50 px-2 py-0.5 text-xs font-semibold text-teal-700">
                      {placeCounts[p.id] ?? 0}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
