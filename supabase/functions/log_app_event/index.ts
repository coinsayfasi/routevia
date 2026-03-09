import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

const allowed = new Set([
  "onboarding_completed",
  "plan_generated",
  "plan_shared",
  "place_shared",
  "referral_shared",
  "referral_redeemed",
  "rating_prompt_shown",
  "rating_submitted",
]);

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = await req.json().catch(() => ({}));

    const eventName = String(body.event_name ?? "");
    if (!allowed.has(eventName)) return jsonResponse({ error: "event_name geçersiz" }, 400);

    const payload = body.payload && typeof body.payload === "object" ? body.payload : {};

    const service = getServiceClient();
    const ins = await service.from("app_events").insert({
      user_id: user.id,
      event_name: eventName,
      payload,
    });

    if (ins.error) return jsonResponse({ error: ins.error.message }, 500);

    return jsonResponse({ ok: true });
  } catch (error) {
    return errorResponse(error);
  }
});
