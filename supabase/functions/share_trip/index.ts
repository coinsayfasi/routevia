import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

function randomToken(): string {
  return crypto.randomUUID().replaceAll("-", "");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const { trip_id } = (await req.json()) as { trip_id?: string };

    if (!trip_id) return jsonResponse({ error: "trip_id is required" }, 400);

    const service = getServiceClient();

    const trip = await service
      .from("trips_clean")
      .select("id")
      .eq("id", trip_id)
      .eq("user_id", user.id)
      .maybeSingle();

    if (trip.error || !trip.data) return jsonResponse({ error: "trip_not_found" }, 404);

    const existing = await service
      .from("trip_shares_clean")
      .select("share_token,is_active")
      .eq("trip_id", trip_id)
      .eq("is_active", true)
      .maybeSingle();

    if (!existing.error && existing.data?.share_token) {
      return jsonResponse({ token: existing.data.share_token });
    }

    const token = randomToken();
    const insert = await service
      .from("trip_shares_clean")
      .insert({ trip_id, share_token: token, is_active: true });

    if (insert.error) return jsonResponse({ error: "share_create_failed" }, 500);

    return jsonResponse({ token });
  } catch (error) {
    return errorResponse(error);
  }
});
