import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

type Payload = {
  province_slug?: string;
  limit?: number;
};

const seasonalCategoryByMonth: Record<number, string[]> = {
  1: ["museum", "historical", "cafe"],
  2: ["museum", "historical", "cafe"],
  3: ["nature", "historical", "viewpoint"],
  4: ["nature", "viewpoint", "beach"],
  5: ["beach", "nature", "viewpoint"],
  6: ["beach", "nature", "activity"],
  7: ["beach", "nature", "waterfall"],
  8: ["beach", "nature", "waterfall"],
  9: ["nature", "historical", "viewpoint"],
  10: ["historical", "museum", "nature"],
  11: ["museum", "historical", "cafe"],
  12: ["museum", "historical", "cafe"],
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json().catch(() => ({}))) as Payload;
    const limit = Math.max(3, Math.min(Number(body.limit ?? 12), 30));

    const service = getServiceClient();

    let cityName: string | null = null;
    let provinceLat: number | null = null;
    let provinceLng: number | null = null;
    if (body.province_slug) {
      const province = await service
        .from("provinces")
        .select("name,lat,lng")
        .eq("slug", body.province_slug)
        .maybeSingle();
      cityName = (province.data?.name as string | undefined) ?? null;
      provinceLat = Number(province.data?.lat ?? NaN);
      provinceLng = Number(province.data?.lng ?? NaN);
      if (!Number.isFinite(provinceLat)) provinceLat = null;
      if (!Number.isFinite(provinceLng)) provinceLng = null;
    }

    const month = new Date().getMonth() + 1;
    const seasonalCats = seasonalCategoryByMonth[month] ?? ["nature", "historical", "cafe"];

    let poiQ = service
      .from("pois")
      .select("id,name,category,city,district,lat,lng,tags,source")
      .eq("provenance_verified", true)
      .in("category", seasonalCats)
      .limit(300);

    if (cityName) poiQ = poiQ.ilike("city", cityName);

    const poiRes = await poiQ;
    if (poiRes.error) return jsonResponse({ error: poiRes.error.message }, 500);
    const pois = (poiRes.data as Record<string, unknown>[] | null) ?? [];

    const ids = pois.map((p) => String(p.id));
    const trustRes = ids.length === 0
      ? { data: [] as Record<string, unknown>[] }
      : await service.from("poi_trust_metrics").select("poi_id,trust_score").in("poi_id", ids);

    const liveRes = ids.length === 0
      ? { data: [] as Record<string, unknown>[] }
      : await service.from("poi_live_status").select("poi_id,sunset_score,crowded_score,quiet_score,tags,confidence").in("poi_id", ids);

    const trustById = new Map<string, number>();
    for (const r of ((trustRes.data as Record<string, unknown>[] | null) ?? [])) {
      trustById.set(String(r.poi_id), Number(r.trust_score ?? 0));
    }

    const liveById = new Map<string, Record<string, unknown>>();
    for (const r of ((liveRes.data as Record<string, unknown>[] | null) ?? [])) {
      liveById.set(String(r.poi_id), r);
    }

    const signalsSince = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString();
    const signalRes = ids.length === 0
      ? { data: [] as Record<string, unknown>[] }
      : await service
        .from("poi_signals")
        .select("poi_id,type,created_at")
        .in("poi_id", ids)
        .gte("created_at", signalsSince)
        .limit(5000);

    const eventByPoi = new Map<string, { fav: number; checkin: number; rating: number }>();
    for (const s of ((signalRes.data as Record<string, unknown>[] | null) ?? [])) {
      const id = String(s.poi_id ?? "");
      if (!id) continue;
      const row = eventByPoi.get(id) ?? { fav: 0, checkin: 0, rating: 0 };
      const t = String(s.type ?? "");
      if (t === "favorite") row.fav += 1;
      if (t === "checkin") row.checkin += 1;
      if (t === "rating") row.rating += 1;
      eventByPoi.set(id, row);
    }

    let weatherScore = 70;
    let weatherMeta: Record<string, unknown> = { source: "fallback" };
    if (provinceLat != null && provinceLng != null) {
      try {
        const w = await fetch(
          `https://api.open-meteo.com/v1/forecast?latitude=${provinceLat}&longitude=${provinceLng}&daily=temperature_2m_max,precipitation_probability_mean&timezone=auto&forecast_days=1`,
          { method: "GET" },
        );
        if (w.ok) {
          const json = await w.json();
          const temp = Number(json?.daily?.temperature_2m_max?.[0] ?? NaN);
          const rain = Number(json?.daily?.precipitation_probability_mean?.[0] ?? NaN);
          if (Number.isFinite(temp) && Number.isFinite(rain)) {
            const tempScore = temp >= 16 && temp <= 29 ? 100 : temp >= 10 && temp <= 34 ? 70 : 45;
            const rainScore = rain <= 20 ? 100 : rain <= 45 ? 70 : 40;
            weatherScore = Math.round(tempScore * 0.6 + rainScore * 0.4);
            weatherMeta = {
              source: "open-meteo",
              max_temp_c: temp,
              rain_prob: rain,
            };
          }
        }
      } catch {
        // Keep fallback weather score
      }
    }

    const weekday = new Date().getDay();
    const weekendBoost = weekday === 0 || weekday === 6 ? 8 : 0;

    const scored = pois.map((p) => {
      const id = String(p.id);
      const trust = trustById.get(id) ?? 0;
      const live = liveById.get(id) ?? {};
      const ev = eventByPoi.get(id) ?? { fav: 0, checkin: 0, rating: 0 };
      const sunset = Number(live.sunset_score ?? 0);
      const quiet = Number(live.quiet_score ?? 0);
      const crowded = Number(live.crowded_score ?? 0);
      const confidence = Number(live.confidence ?? 0);

      const monthBoost = seasonalCats.includes(String(p.category)) ? 18 : 0;
      const liveBoost = sunset * 0.12 + quiet * 0.08 - crowded * 0.05;
      const eventScore = Math.min(100, ev.fav * 6 + ev.checkin * 4 + ev.rating * 3);
      const score =
        trust * 0.45 +
        monthBoost +
        liveBoost +
        confidence * 0.06 +
        eventScore * 0.18 +
        weatherScore * 0.12 +
        weekendBoost;

      return {
        id,
        name: String(p.name ?? ""),
        category: String(p.category ?? "activity"),
        city: String(p.city ?? ""),
        district: String(p.district ?? ""),
        lat: Number(p.lat ?? 0),
        lng: Number(p.lng ?? 0),
        tags: Array.isArray(p.tags) ? p.tags : [],
        season_score: Number(score.toFixed(2)),
        trust_score: Number(trust.toFixed(2)),
        event_score: Number(eventScore.toFixed(2)),
        weather_score: weatherScore,
        live_tags: Array.isArray(live.tags) ? live.tags : [],
        why: `Mevsim + trust + canli sinyal + etkinlik + hava`,
      };
    })
      .filter((p) => Number.isFinite(p.lat) && Number.isFinite(p.lng))
      .sort((a, b) => b.season_score - a.season_score)
      .slice(0, limit);

    return jsonResponse({
      items: scored,
      meta: {
        month,
        seasonal_categories: seasonalCats,
        province_slug: body.province_slug ?? null,
        weather: weatherMeta,
        weekend_boost: weekendBoost,
      },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
