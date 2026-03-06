import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

type Place = {
  id?: string;
  category?: string;
  tags?: string[];
};

type Stop = {
  order_index?: number;
  arrival_time?: string;
  duration_min?: number;
  transport_mode?: string;
  place?: Place;
};

type Day = {
  day_number?: number;
  stops?: Stop[];
};

type Payload = {
  days_plan?: Day[];
  pace?: string;
  persona_mode?: string;
  preferences?: string[];
  premium?: boolean;
};

function norm(v: unknown): string {
  return String(v ?? "").trim().toLowerCase();
}

function scoreStop(stop: Stop, prefs: Set<string>, persona: string, pace: string, live: Record<string, Record<string, unknown>>, trust: Record<string, number>): number {
  const placeId = String(stop.place?.id ?? "");
  const category = norm(stop.place?.category);
  const tags = new Set((stop.place?.tags ?? []).map((t) => norm(t)));
  const liveItem = live[placeId] ?? {};
  const trustScore = trust[placeId] ?? 0;

  let s = 0;
  if (prefs.has(category)) s += 20;
  for (const p of prefs) {
    if (tags.has(p)) s += 8;
  }

  if (persona === "photo" && (category === "viewpoint" || category === "beach" || Number(liveItem.sunset_score ?? 0) > 35)) s += 16;
  if (persona === "family" && Number(liveItem.family_score ?? 0) > 30) s += 16;
  if (persona === "relax" && Number(liveItem.quiet_score ?? 0) > 30) s += 14;
  if (persona === "budget" && tags.has("budget")) s += 12;

  if (pace === "slow") s += Math.max(0, 15 - (Number(stop.duration_min ?? 60) / 10));
  if (pace === "fast") s += Math.min(12, Number(stop.duration_min ?? 60) / 15);

  s += (trustScore / 100) * 22;

  if (Number(liveItem.crowded_score ?? 0) >= 55 && persona !== "family") s -= 9;
  if (Number(liveItem.confidence ?? 0) < 20) s -= 4;

  return s;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json().catch(() => ({}))) as Payload;
    const days = Array.isArray(body.days_plan) ? body.days_plan : [];
    if (days.length === 0) return jsonResponse({ error: "days_plan_required" }, 400);

    const prefs = new Set((body.preferences ?? []).map((p) => norm(p)).filter(Boolean));
    const persona = norm(body.persona_mode || "relax");
    const pace = norm(body.pace || "medium");
    const premium = Boolean(body.premium);

    const placeIds = Array.from(
      new Set(
        days.flatMap((d) => (d.stops ?? []).map((s) => String(s.place?.id ?? "")).filter((x) => /^[0-9a-fA-F-]{36}$/.test(x)))
      )
    );

    const service = getServiceClient();
    let liveMap: Record<string, Record<string, unknown>> = {};
    let trustMap: Record<string, number> = {};

    if (placeIds.length > 0) {
      const live = await service
        .from("poi_live_status")
        .select("poi_id,crowded_score,family_score,sunset_score,quiet_score,confidence")
        .in("poi_id", placeIds);
      for (const row of ((live.data as Record<string, unknown>[] | null) ?? [])) {
        liveMap[String(row.poi_id)] = row;
      }

      const trust = await service
        .from("poi_trust_metrics")
        .select("poi_id,trust_score")
        .in("poi_id", placeIds);
      for (const row of ((trust.data as Record<string, unknown>[] | null) ?? [])) {
        trustMap[String(row.poi_id)] = Number(row.trust_score ?? 0);
      }
    }

    const optimizedDays = days.map((d) => {
      const scored = (d.stops ?? []).map((s) => ({
        stop: s,
        score: scoreStop(s, prefs, persona, pace, liveMap, trustMap),
      }));

      scored.sort((a, b) => b.score - a.score);

      const limited = premium ? scored : scored.slice(0, Math.min(scored.length, 7));
      const stops = limited.map((x, idx) => ({
        ...x.stop,
        order_index: idx + 1,
      }));

      return {
        day_number: Number(d.day_number ?? 1),
        stops,
      };
    });

    return jsonResponse({
      days_plan: optimizedDays,
      meta: {
        optimized: true,
        premium_used: premium,
        reason: premium ? "live+trust+profile" : "profile_basic",
      },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
