import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = await req.json().catch(() => ({}));

    const placeId = String(body.place_id ?? "");
    const type = String(body.type ?? "");
    const rating = body.rating == null ? null : Number(body.rating);

    if (!placeId) return jsonResponse({ error: "place_id gerekli" }, 400);
    if (!["checkin", "favorite", "rating"].includes(type)) return jsonResponse({ error: "type geçersiz" }, 400);
    if (type === "rating" && (rating == null || !Number.isFinite(rating) || rating < 1 || rating > 5)) {
      return jsonResponse({ error: "rating 1-5 olmalı" }, 400);
    }

    const service = getServiceClient();
    const poi = await service
      .from("pois")
      .select("id")
      .eq("provenance_verified", true)
      .eq("id", placeId)
      .maybeSingle();
    if (!poi.data?.id) return jsonResponse({ error: "place_not_found" }, 404);

    if (type === "favorite" || type === "checkin") {
      const upsert = await service
        .from("poi_signals")
        .upsert({
          user_id: user.id,
          poi_id: placeId,
          type,
          rating: null,
        }, { onConflict: "user_id,poi_id,type" })
        .select("id")
        .single();
      if (upsert.error) return jsonResponse({ error: upsert.error.message }, 500);
    } else {
      // rating is append-only for signal history
      const ins = await service
        .from("poi_signals")
        .insert({
          user_id: user.id,
          poi_id: placeId,
          type,
          rating,
        })
        .select("id")
        .single();
      if (ins.error) return jsonResponse({ error: ins.error.message }, 500);
    }

    const stats = await service.rpc("get_poi_stats", { p_poi_id: placeId });

    await service.from("app_events").insert({
      user_id: user.id,
      event_name: type === "favorite" ? "place_favorited" : type === "checkin" ? "place_checked_in" : "place_rated",
      payload: { place_id: placeId, rating },
    });

    return jsonResponse({ ok: true, stats: stats.data ?? null });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
