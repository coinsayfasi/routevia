import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdmin, requireUser } from "../_shared/client.ts";

type SeedRow = {
  province_slug: string;
  district_slug: string;
  name: string;
  slug: string;
  category: string;
  lat: number;
  lng: number;
  short_summary: string;
  best_time: string;
  duration_min: number;
  tags: string[];
  popularity_score: number;
};

function parseCsv(csv: string): SeedRow[] {
  const lines = csv.split(/\r?\n/).filter(Boolean);
  if (lines.length < 2) return [];

  const headers = lines[0].split(",").map((h) => h.trim());
  return lines.slice(1).map((line) => {
    const parts = line.split(",").map((v) => v.trim());
    const row = Object.fromEntries(headers.map((h, i) => [h, parts[i] ?? ""])) as Record<string, string>;
    return {
      province_slug: row.province_slug,
      district_slug: row.district_slug,
      name: row.name,
      slug: row.slug,
      category: row.category,
      lat: Number(row.lat),
      lng: Number(row.lng),
      short_summary: row.short_summary.slice(0, 160),
      best_time: row.best_time,
      duration_min: Number(row.duration_min),
      tags: row.tags ? row.tags.split("|") : [],
      popularity_score: Number(row.popularity_score || 50),
    };
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    await requireAdmin(user.id);

    const payload = await req.json() as { rows?: SeedRow[]; csv?: string };
    const rows = payload.rows ?? (payload.csv ? parseCsv(payload.csv) : []);

    if (!rows.length) {
      return jsonResponse({ error: "No seed rows supplied" }, 400);
    }

    const service = getServiceClient();
    let upserted = 0;

    for (const row of rows) {
      const { data: province } = await service
        .from("provinces")
        .select("id")
        .eq("slug", row.province_slug)
        .single();
      if (!province) continue;

      const { data: district } = await service
        .from("districts")
        .select("id")
        .eq("province_id", province.id)
        .eq("slug", row.district_slug)
        .maybeSingle();

      const placeRecord = {
        province_id: province.id,
        district_id: district?.id ?? null,
        name: row.name,
        slug: row.slug,
        category: row.category,
        geog: `SRID=4326;POINT(${row.lng} ${row.lat})`,
        short_summary: row.short_summary,
        best_time: row.best_time,
        duration_min: row.duration_min,
        tags: row.tags,
        popularity_score: row.popularity_score,
      };

      const { error } = await service.from("places").upsert(placeRecord, { onConflict: "province_id,slug" });
      if (!error) upserted += 1;
    }

    return jsonResponse({ upserted });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
