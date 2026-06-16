import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = await req.json().catch(() => ({}));
    const message = String(body.message ?? "").trim();
    const rating = body.rating == null ? null : Number(body.rating);

    if (!message || message.length < 4) {
      return jsonResponse({ error: "Mesaj çok kısa" }, 400);
    }
    if (message.length > 1200) {
      return jsonResponse({ error: "Mesaj çok uzun" }, 400);
    }
    if (rating != null && (!Number.isFinite(rating) || rating < 1 || rating > 5)) {
      return jsonResponse({ error: "Puan 1-5 olmalı" }, 400);
    }

    const service = getServiceClient();
    const ins = await service
      .from("feedback")
      .insert({
        user_id: user.id,
        message,
        rating,
      })
      .select("id")
      .maybeSingle();

    if (ins.error) return jsonResponse({ error: ins.error.message }, 500);

    await service.from("app_events").insert({
      user_id: user.id,
      event_name: "rating_submitted",
      payload: { rating },
    });

    return jsonResponse({ ok: true, id: ins.data.id });
  } catch (error) {
    return errorResponse(error);
  }
});
