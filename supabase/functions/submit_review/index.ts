import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

type SubmitReviewPayload = {
  place_id?: string;
  rating?: number;
  flags?: string[];
  comment_short?: string;
};

const allowedFlags = new Set([
  "crowded",
  "family",
  "quiet",
  "photo_spot",
  "budget",
  "sunset_worthy",
]);

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
    const body = (await req.json()) as SubmitReviewPayload;

    if (!body.place_id) {
      return jsonResponse({ error: "place_id is required" }, 400);
    }

    const rating = Number(body.rating ?? 0);
    const commentShort = String(body.comment_short ?? "").trim();
    const flags = (body.flags ?? []).map((f) => String(f));

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return jsonResponse({ error: "rating must be integer 1..5" }, 400);
    }

    if (commentShort.length > 240) {
      return jsonResponse({ error: "comment_short max 240 chars" }, 400);
    }

    const invalidFlags = flags.filter((f) => !allowedFlags.has(f));
    if (invalidFlags.length > 0) {
      return jsonResponse({ error: `Invalid flags: ${invalidFlags.join(", ")}` }, 400);
    }
    const service = getServiceClient();

    const { data: poi, error: poiError } = await service
      .from("pois")
      .select("id")
      .eq("provenance_verified", true)
      .eq("id", body.place_id)
      .single();

    if (poiError || !poi) {
      return jsonResponse({ error: "Place not found" }, 404);
    }

    const { error: upsertError } = await service
      .from("poi_reviews")
      .upsert(
        {
          user_id: user.id,
          poi_id: body.place_id,
          rating,
          flags,
          comment_short: commentShort,
        },
        {
          onConflict: "user_id,poi_id",
        }
      );

    if (upsertError) {
      return jsonResponse({ error: upsertError.message }, 500);
    }

    const { data: stats, error: statsError } = await service.rpc("get_poi_stats", {
      p_poi_id: body.place_id,
    });

    if (statsError) {
      return jsonResponse({ error: statsError.message }, 500);
    }

    return jsonResponse({ ok: true, stats });
  } catch (error) {
    return errorResponse(error);
  }
});
