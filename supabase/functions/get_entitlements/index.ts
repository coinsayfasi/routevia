import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const service = getServiceClient();

    const rows = await service
      .from("user_entitlements")
      .select("entitlement_key,expires_at")
      .eq("user_id", user.id)
      .gte("expires_at", new Date().toISOString())
      .order("expires_at", { ascending: false });

    if (rows.error) return jsonResponse({ error: rows.error.message }, 500);

    return jsonResponse({ items: rows.data ?? [] });
  } catch (error) {
    return errorResponse(error);
  }
});
