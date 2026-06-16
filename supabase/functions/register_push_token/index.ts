import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as { token?: string; platform?: string };
    const token = String(body.token ?? "").trim();
    const platform = String(body.platform ?? "").trim().toLowerCase();

    if (!token) return jsonResponse({ error: "token is required" }, 400);
    if (platform !== "android" && platform !== "ios") {
      return jsonResponse({ error: "platform must be android or ios" }, 400);
    }

    const service = getServiceClient();
    const { error } = await service.from("user_push_tokens").upsert({
      user_id: user.id,
      token,
      platform,
      enabled: true,
      last_seen_at: new Date().toISOString(),
    }, {
      onConflict: "token",
    });

    if (error) return jsonResponse({ error: error.message }, 500);
    return jsonResponse({ ok: true });
  } catch (error) {
    return errorResponse(error);
  }
});
