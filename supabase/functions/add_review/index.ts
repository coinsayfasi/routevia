import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { countDailyRows, ensurePlaceExists, getUtcDayStartIso } from "../_shared/community.ts";

type AddReviewPayload = {
  place_id?: string;
  rating?: number;
  comment?: string;
  flags?: string[];
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as AddReviewPayload;

    const placeId = String(body.place_id ?? "").trim();
    const rating = Number(body.rating ?? 0);
    const comment = String(body.comment ?? "").trim();
    const flags = (body.flags ?? [])
      .map((item) => String(item).trim())
      .filter((item) => item.length > 0);

    if (!placeId) return jsonResponse({ error: "place_id is required" }, 400);
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return jsonResponse({ error: "rating must be an integer between 1 and 5" }, 400);
    }
    if (comment.length > 1200) {
      return jsonResponse({ error: "comment max 1200 chars" }, 400);
    }

    await ensurePlaceExists(placeId);
    const service = getServiceClient();
    const { data: existing, error: existingError } = await service
      .from("place_reviews")
      .select("id")
      .eq("place_id", placeId)
      .eq("user_id", user.id)
      .maybeSingle();

    if (existingError) {
      return jsonResponse({ error: existingError.message }, 500);
    }

    if (!existing) {
      const createdToday = await countDailyRows("place_reviews", user.id, getUtcDayStartIso());
      if (createdToday >= 3) {
        return jsonResponse({
          error: "daily_review_limit_exceeded",
          message: "Günlük yorum sınırına ulaştın. Bugün en fazla 3 yorum ekleyebilirsin.",
        }, 429);
      }
    }

    const { error: upsertError } = await service
      .from("place_reviews")
      .upsert({
        place_id: placeId,
        user_id: user.id,
        rating,
        comment,
        flags,
        status: "pending",
      }, {
        onConflict: "place_id,user_id",
      });

    if (upsertError) {
      return jsonResponse({ error: upsertError.message }, 500);
    }

    const { data: reviews, error: reviewsError } = await service.rpc("get_place_reviews", {
      p_place_id: placeId,
      p_limit: 20,
      p_user_id: user.id,
    });
    if (reviewsError) {
      return jsonResponse({ error: reviewsError.message }, 500);
    }

    return jsonResponse({ ok: true, reviews });
  } catch (error) {
    return errorResponse(error);
  }
});
