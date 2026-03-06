import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

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

function classifyCategory(name: string): string {
  const n = name.toLowerCase();
  if (n.includes("müze") || n.includes("muze")) return "museum";
  if (n.includes("plaj") || n.includes("beach")) return "beach";
  if (n.includes("kale") || n.includes("antik") || n.includes("cami") || n.includes("kilise")) return "historical";
  if (n.includes("şelale") || n.includes("kanyon") || n.includes("göl") || n.includes("orman")) return "nature";
  if (n.includes("seyir") || n.includes("manzara") || n.includes("tepe")) return "viewpoint";
  if (n.includes("kafe") || n.includes("kahve")) return "cafe";
  if (n.includes("restoran") || n.includes("lokanta")) return "food";
  return "activity";
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = await req.json() as {
      raw_table?: string;
      limit?: number;
      offset?: number;
      province_slug?: string;
      province_name?: string;
    };
    const rawTable = String(body.raw_table ?? "places");
    const limit = Math.max(1, Math.min(5000, Number(body.limit ?? 1000)));
    const offset = Math.max(0, Number(body.offset ?? 0));
    const provinceSlugFilter = body.province_slug ? normalizeSlug(String(body.province_slug)) : null;
    const provinceNameFilter = body.province_name ? String(body.province_name).trim() : null;

    const service = getServiceClient();

    const selectCols = "id,name,lat,lng,province,district,source_kind";

    let rawQuery = service
      .from(rawTable)
      .select(selectCols)
      .range(offset, offset + limit - 1);

    rawQuery = rawQuery.eq("source_kind", "curated");
    if (provinceNameFilter) {
      rawQuery = rawQuery.eq("province", provinceNameFilter);
    }

    const rawRows = await rawQuery;

    if (rawRows.error) return jsonResponse({ error: rawRows.error.message }, 500);

    let inserted = 0;
    let linked = 0;

    for (const rr of ((rawRows.data as Record<string, unknown>[] | null) ?? [])) {
      const name = String(rr.name ?? "").trim();
      const lat = Number(rr.lat ?? NaN);
      const lng = Number(rr.lng ?? NaN);
      const provinceText = String(rr.province ?? "").trim();
      const districtText = String(rr.district ?? "").trim();
      if (!name || !Number.isFinite(lat) || !Number.isFinite(lng) || !provinceText) continue;
      if (/core\s*spot|çekirdek|dummy|placeholder/i.test(name)) continue;
      if (provinceSlugFilter && normalizeSlug(provinceText) != provinceSlugFilter) continue;

      const provinceSlug = normalizeSlug(provinceText);
      const districtSlug = normalizeSlug(districtText);
      const placeSlug = normalizeSlug(name);

      const province = await service.from("provinces").select("id").eq("slug", provinceSlug).maybeSingle();
      if (!province.data?.id) continue;

      const district = await service
        .from("districts")
        .select("id")
        .eq("province_id", province.data.id)
        .eq("slug", districtSlug)
        .maybeSingle();

      const category = classifyCategory(name);
      const summary = `${provinceText} bölgesinde öne çıkan ${name} noktası.`;

      const upsert = await service.from("places_clean").upsert({
        province_id: province.data.id,
        district_id: district.data?.id ?? null,
        name,
        slug: placeSlug,
        category,
        geog: `SRID=4326;POINT(${lng} ${lat})`,
        short_summary: summary.slice(0, 160),
        best_time: "day",
        duration_min: 60,
        tags: [category],
        popularity_score: 0,
      }, { onConflict: "province_id,slug" }).select("id").single();

      if (upsert.error || !upsert.data?.id) continue;
      inserted += 1;

      if (rr.id) {
        await service.from("raw_place_links_clean").upsert({
          raw_table: rawTable,
          raw_pk: String(rr.id),
          clean_place_id: String(upsert.data.id),
        }, { onConflict: "raw_table,raw_pk" });
        linked += 1;
      }
    }

    return jsonResponse({
      raw_table: rawTable,
      offset,
      province_slug: provinceSlugFilter,
      province_name: provinceNameFilter,
      scanned: ((rawRows.data as unknown[]) ?? []).length,
      inserted,
      linked,
      raw_has_google_columns: true,
      ignored_raw_columns: ["google_* (kopyalanmaz)"],
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
