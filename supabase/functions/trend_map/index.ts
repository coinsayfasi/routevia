import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

type Payload = {
  province_slug?: string;
  limit?: number;
};

function normalizeText(value: string): string {
  return value
    .toLocaleLowerCase("tr-TR")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "");
}

function hasLodgingSignal(name: string, category: string, tags: unknown): boolean {
  const flat = [
    normalizeText(name),
    normalizeText(category),
    ...(Array.isArray(tags) ? tags.map((tag) => normalizeText(String(tag))) : []),
  ];
  return flat.some((value) =>
    ["lodging", "hotel", "bungalow", "bungalov", "villa", "resort", "glamping", "butikotel", "boutiquehotel", "suitotel", "suitehotel", "konaklama"]
      .some((needle) => value.includes(needle))
  );
}

function dedupeKey(item: Record<string, unknown>): string {
  const lat = Number(item.lat ?? 0).toFixed(3);
  const lng = Number(item.lng ?? 0).toFixed(3);
  return `${normalizeText(String(item.name ?? ""))}:${lat}:${lng}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json().catch(() => ({}))) as Payload;
    const limit = Math.max(10, Math.min(Number(body.limit ?? 120), 300));
    const service = getServiceClient();

    let cityName: string | null = null;
    if (body.province_slug) {
      const province = await service
        .from("provinces")
        .select("name")
        .eq("slug", body.province_slug)
        .maybeSingle();
      cityName = (province.data?.name as string | undefined) ?? null;
    }

    let poiQ = service
      .from("pois")
      .select("id,name,category,city,district,lat,lng,tags,coordinate_source")
      .eq("provenance_verified", true)
      .limit(limit);
    if (cityName) poiQ = poiQ.eq("city", cityName);

    const poiRes = await poiQ;
    if (poiRes.error) return jsonResponse({ error: poiRes.error.message }, 500);

    const pois = (poiRes.data as Record<string, unknown>[] | null) ?? [];
    const ids = pois.map((p) => String(p.id));

    const trustRes = ids.length === 0
      ? { data: [] as Record<string, unknown>[] }
      : await service.from("poi_trust_metrics").select("poi_id,trust_score").in("poi_id", ids);
    const liveRes = ids.length === 0
      ? { data: [] as Record<string, unknown>[] }
      : await service.from("poi_live_status").select("poi_id,crowded_score,sunset_score,family_score,quiet_score,confidence").in("poi_id", ids);

    const trustById = new Map<string, number>();
    for (const r of ((trustRes.data as Record<string, unknown>[] | null) ?? [])) {
      trustById.set(String(r.poi_id), Number(r.trust_score ?? 0));
    }

    const liveById = new Map<string, Record<string, unknown>>();
    for (const r of ((liveRes.data as Record<string, unknown>[] | null) ?? [])) {
      liveById.set(String(r.poi_id), r);
    }

    const items = pois
      .filter((p) => !hasLodgingSignal(String(p.name ?? ""), String(p.category ?? ""), p.tags))
      .map((p) => {
        const id = String(p.id);
        const trust = trustById.get(id) ?? 0;
        const live = liveById.get(id) ?? {};
        const crowded = Number(live.crowded_score ?? 0);
        const sunset = Number(live.sunset_score ?? 0);
        const family = Number(live.family_score ?? 0);
        const quiet = Number(live.quiet_score ?? 0);
        const confidence = Number(live.confidence ?? 0);

        const trendScore = trust * 0.55 + crowded * 0.15 + sunset * 0.1 + family * 0.1 + quiet * 0.05 + confidence * 0.05;

        return {
          id,
          name: String(p.name ?? ""),
          category: String(p.category ?? "activity"),
          city: String(p.city ?? ""),
          district: String(p.district ?? ""),
          lat: Number(p.lat ?? 0),
          lng: Number(p.lng ?? 0),
          trend_score: Number(trendScore.toFixed(2)),
          trust_score: Number(trust.toFixed(2)),
        };
      })
      .filter((x) => Number.isFinite(x.lat) && Number.isFinite(x.lng))
      .sort((a, b) => b.trend_score - a.trend_score);

    const deduped = new Map<string, typeof items[number]>();
    for (const item of items) {
      const key = dedupeKey(item);
      if (!deduped.has(key)) deduped.set(key, item);
    }

    return jsonResponse({
      items: [...deduped.values()].slice(0, limit),
      meta: { province_slug: body.province_slug ?? null },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
