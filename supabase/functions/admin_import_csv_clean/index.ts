import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { parse } from "https://deno.land/std@0.224.0/csv/mod.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";

function normalizeSlug(input: string): string {
  return input
    .toLowerCase()
    .trim()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrService(authHeader);

    const body = await req.json() as { csv_text?: string };
    const csvText = body.csv_text?.trim();
    if (!csvText) return jsonResponse({ error: "csv_text_required" }, 400);

    if (/google_/i.test(csvText)) {
      return jsonResponse({ error: "google_fields_not_allowed" }, 400);
    }

    const rows = parse(csvText, { skipFirstRow: false }) as string[][];
    if (rows.length < 2) return jsonResponse({ error: "csv_empty" }, 400);

    const headers = rows[0].map((h) => h.trim());
    const required = ["name", "province", "district", "category", "lat", "lng", "short_desc"];
    for (const r of required) {
      if (!headers.includes(r)) return jsonResponse({ error: `missing_column_${r}` }, 400);
    }

    const idx = (k: string) => headers.indexOf(k);
    const service = getServiceClient();

    let inserted = 0;
    let updated = 0;

    for (const row of rows.slice(1)) {
      const name = String(row[idx("name")] ?? "").trim();
      const provinceName = String(row[idx("province")] ?? "").trim();
      const districtName = String(row[idx("district")] ?? "").trim();
      const category = String(row[idx("category")] ?? "activity").trim();
      const lat = Number(row[idx("lat")] ?? NaN);
      const lng = Number(row[idx("lng")] ?? NaN);
      const shortDesc = String(row[idx("short_desc")] ?? "").trim();

      if (!name || !provinceName || !Number.isFinite(lat) || !Number.isFinite(lng)) continue;

      const provinceSlug = normalizeSlug(provinceName);
      const districtSlug = normalizeSlug(districtName);
      const placeSlug = normalizeSlug(name);

      const province = await service.from("provinces").select("id").eq("slug", provinceSlug).maybeSingle();
      if (!province.data?.id) continue;

      const district = await service
        .from("districts")
        .select("id")
        .eq("province_id", province.data.id)
        .eq("slug", districtSlug)
        .maybeSingle();

      const upsert = await service.from("places_clean").upsert({
        province_id: province.data.id,
        district_id: district.data?.id ?? null,
        name,
        slug: placeSlug,
        category,
        geog: `SRID=4326;POINT(${lng} ${lat})`,
        short_summary: shortDesc.slice(0, 160),
        best_time: "day",
        duration_min: 60,
        tags: [],
        popularity_score: 0,
        coordinate_source: "admin_verified",
        coordinate_verified_at: new Date().toISOString(),
        coordinate_verified_by: "admin_csv_import",
      }, { onConflict: "province_id,slug" }).select("id").maybeSingle();

      if (upsert.error || !upsert.data?.id) continue;
      if (upsert.status === 201) inserted += 1; else updated += 1;
    }

    return jsonResponse({ inserted, updated, total_rows: rows.length - 1 });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
