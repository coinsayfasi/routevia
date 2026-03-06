import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

type Payload = {
  place_ids?: string[];
  hours?: number;
  limit?: number;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json().catch(() => ({}))) as Payload;
    const placeIds = (body.place_ids ?? [])
      .map((v) => String(v).trim())
      .filter((v) => /^[0-9a-fA-F-]{36}$/.test(v))
      .slice(0, 120);
    const hours = Math.max(1, Math.min(Number(body.hours ?? 6), 24));
    const limit = Math.max(1, Math.min(Number(body.limit ?? 50), 120));

    const service = getServiceClient();

    for (const id of placeIds) {
      await service.rpc("refresh_poi_live_status", { p_poi_id: id, p_hours: hours });
    }

    let q = service
      .from("poi_live_status")
      .select("poi_id,crowded_score,family_score,sunset_score,quiet_score,tags,confidence,last_event_at,updated_at")
      .order("updated_at", { ascending: false })
      .limit(limit);

    if (placeIds.length > 0) {
      q = q.in("poi_id", placeIds);
    }

    const { data, error } = await q;
    if (error) return jsonResponse({ error: error.message }, 500);

    const items = ((data as Record<string, unknown>[] | null) ?? []).map((row) => {
      const rawTags = (Array.isArray(row.tags) ? row.tags : [])
        .map((v) => String(v))
        .filter(Boolean);
      const crowdedScore = Number(row.crowded_score ?? 0);
      const familyScore = Number(row.family_score ?? 0);
      const sunsetScore = Number(row.sunset_score ?? 0);
      const quietScore = Number(row.quiet_score ?? 0);
      const confidence = Number(row.confidence ?? 0);

      // Confidence gate: low confidence signals should not surface as "live status".
      let tags: string[] = [];
      if (confidence >= 35) {
        if (crowdedScore >= 45) tags.push("kalabalik");
        if (familyScore >= 40) tags.push("aile_uygun");
        if (sunsetScore >= 40) tags.push("gun_batimi");
        if (quietScore >= 45) tags.push("sessiz");
        if (tags.length === 0) {
          tags = rawTags;
        }
      }
      if (confidence < 55 && tags.length > 2) {
        tags = tags.slice(0, 2);
      }

      const tagLabels = tags.map((t) =>
        t === "kalabalik"
          ? "kalabalık"
          : t === "aile_uygun"
          ? "aile uygun"
          : t === "gun_batimi"
          ? "gün batımı"
          : t === "sessiz"
          ? "sessiz"
          : t
      );

      return {
        place_id: String(row.poi_id ?? ""),
        tags,
        tag_labels: tagLabels,
        crowded_score: crowdedScore,
        family_score: familyScore,
        sunset_score: sunsetScore,
        quiet_score: quietScore,
        confidence,
        last_event_at: row.last_event_at,
      };
    });

    return jsonResponse({ items, hours, count: items.length });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
