import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { ensurePlaceExists, getUtcDayStartIso } from "../_shared/community.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as { place_id?: string };
    const placeId = String(body.place_id ?? "").trim();

    if (!placeId) return jsonResponse({ error: "place_id is required" }, 400);
    await ensurePlaceExists(placeId);

    const service = getServiceClient();
    const utcStart = getUtcDayStartIso();
    const { data: existing, error: existingError } = await service
      .from("place_checkins")
      .select("id")
      .eq("place_id", placeId)
      .eq("user_id", user.id)
      .gte("created_at", utcStart)
      .limit(1)
      .maybeSingle();

    if (existingError) return jsonResponse({ error: existingError.message }, 500);
    if (existing) {
      return jsonResponse({
        error: "daily_checkin_exists",
        message: "Bu yer için bugünkü check-in zaten kayıtlı.",
      }, 409);
    }

    const { error: insertError } = await service
      .from("place_checkins")
      .insert({ place_id: placeId, user_id: user.id });

    if (insertError) return jsonResponse({ error: insertError.message }, 500);

    const { data: state, error: stateError } = await service
      .from("place_community_state")
      .select("place_id,routevia_score,avg_rating,review_count,checkins_count,photo_count,cover_photo")
      .eq("place_id", placeId)
      .maybeSingle();

    if (stateError) return jsonResponse({ error: stateError.message }, 500);
    return jsonResponse({ ok: true, community: state ?? {} });
  } catch (error) {
    return errorResponse(error);
  }
});
