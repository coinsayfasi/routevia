import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { ensurePlaceExists } from "../_shared/community.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as { place_id?: string; limit?: number };
    const placeId = String(body.place_id ?? "").trim();
    const limit = Math.max(1, Math.min(50, Number(body.limit ?? 20)));

    if (!placeId) return jsonResponse({ error: "place_id is required" }, 400);
    await ensurePlaceExists(placeId);

    const service = getServiceClient();
    const { data, error } = await service.rpc("get_place_reviews", {
      p_place_id: placeId,
      p_limit: limit,
      p_user_id: user.id,
    });

    if (error) return jsonResponse({ error: error.message }, 500);
    return jsonResponse(data ?? {});
  } catch (error) {
    return errorResponse(error);
  }
});
