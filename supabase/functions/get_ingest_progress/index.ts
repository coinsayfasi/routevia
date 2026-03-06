import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

const SOURCE_KINDS = ["curated", "google", "osm"] as const;
const CATEGORIES = [
  "museum",
  "historical",
  "nature",
  "beach",
  "viewpoint",
  "market",
  "cafe",
  "food",
  "activity",
  "lodging",
  "tour",
  "ski",
  "waterfall",
  "canyon",
  "mall",
] as const;

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET" && req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const service = getServiceClient();

    const sourceCountQueries = SOURCE_KINDS.map((kind) =>
      service.from("places").select("id", { count: "exact", head: true }).eq("source_kind", kind)
    );
    const categoryCountQueries = CATEGORIES.map((category) =>
      service.from("places").select("id", { count: "exact", head: true }).eq("category", category)
    );

    const [districts, jobs, districtRows, placeRows, failedRows, ...countResults] = await Promise.all([
      service.from("districts").select("id", { count: "exact", head: true }),
      service.from("district_ingest_jobs").select("status"),
      service.from("districts").select("id,name,province:provinces(name)"),
      service.from("places").select("district_id"),
      service
        .from("district_ingest_jobs")
        .select("id,district_id,attempts,last_error,updated_at")
        .eq("status", "failed")
        .order("updated_at", { ascending: false })
        .limit(20),
      ...sourceCountQueries,
      ...categoryCountQueries,
    ]);

    const status = { queued: 0, running: 0, done: 0, failed: 0 };
    for (const row of ((jobs.data as Record<string, unknown>[] | null) ?? [])) {
      const key = String(row.status);
      if (key in status) status[key as keyof typeof status] += 1;
    }

    const sourceCounts: Record<string, number> = {};
    SOURCE_KINDS.forEach((kind, index) => {
      sourceCounts[kind] = countResults[index].count ?? 0;
    });

    const categoryCounts: Record<string, number> = {};
    CATEGORIES.forEach((category, idx) => {
      const result = countResults[SOURCE_KINDS.length + idx];
      const count = result.count ?? 0;
      if (count > 0) categoryCounts[category] = count;
    });

    const districtCounts = new Map<string, number>();
    for (const row of ((placeRows.data as Record<string, unknown>[] | null) ?? [])) {
      const districtId = row.district_id ? String(row.district_id) : "";
      if (!districtId) continue;
      districtCounts.set(districtId, (districtCounts.get(districtId) ?? 0) + 1);
    }
    const bottom = ((districtRows.data as Record<string, unknown>[] | null) ?? [])
      .map((d) => ({
        district_id: String(d.id),
        district_name: String(d.name),
        province_name: String(((d.province as Record<string, unknown> | null) ?? {})["name"] ?? ""),
        place_count: districtCounts.get(String(d.id)) ?? 0,
      }))
      .sort((a, b) => (a.place_count - b.place_count) || a.district_name.localeCompare(b.district_name))
      .slice(0, 20);

    return jsonResponse({
      total_districts: districts.count ?? 0,
      jobs: status,
      places_by_source: sourceCounts,
      places_by_category: categoryCounts,
      bottom_20_districts: bottom,
      recent_failed_jobs: ((failedRows.data as Record<string, unknown>[] | null) ?? []),
      diagnostics: {
        google_pipeline_enabled: false,
        policy_mode: "clean_only",
        overpass_configured: Boolean(Deno.env.get("OVERPASS_URL")),
      },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
