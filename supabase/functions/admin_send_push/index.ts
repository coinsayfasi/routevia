import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";
import { getFirebaseCreds, sendFirebasePushBatch } from "../_shared/firebase.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

type Payload = {
  user_id?: string;
  title?: string;
  body?: string;
  data?: Record<string, string>;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const admin = await requireAdminOrService(authHeader);

    const payload = (await req.json()) as Payload;
    const title = String(payload.title ?? "Routevia").trim();
    const body = String(payload.body ?? "").trim();
    const data = payload.data ?? {};
    const targetUserId = payload.user_id ? String(payload.user_id).trim() : null;

    if (!body) return jsonResponse({ error: "body is required" }, 400);

    // Firebase credentials check — return a 200 with a clear skipped reason so
    // the mobile admin panel can display a helpful setup message.
    if (!getFirebaseCreds()) {
      return jsonResponse({ ok: false, skipped: "firebase_secrets_missing" });
    }

    const service = getServiceClient();

    let query = service
      .from("user_push_tokens")
      .select("id,user_id,token,platform")
      .eq("enabled", true)
      .order("updated_at", { ascending: false });

    if (targetUserId) {
      query = query.eq("user_id", targetUserId).limit(5);
    } else {
      query = query.limit(500);
    }

    const { data: tokens, error: tokenError } = await query;
    if (tokenError) return jsonResponse({ error: tokenError.message }, 500);
    if (!tokens || tokens.length === 0) {
      return jsonResponse({ ok: true, skipped: "no_push_tokens", sent: 0 });
    }

    // Send all notifications in parallel (one OAuth token minted, reused for all).
    const messages = tokens.map((row) => ({
      token: String(row.token),
      title,
      body,
      data: { type: "admin_broadcast", ...data },
    }));

    const { sent, failed } = await sendFirebasePushBatch(messages);

    // Fire-and-forget audit log — failure is non-critical.
    service.from("admin_notifications").insert({
      sent_by: (admin as { id: string }).id,
      target_user_id: targetUserId ?? null,
      title,
      body,
      data,
      success_count: sent,
      fail_count: failed,
    }).then(() => {}).catch(() => {});

    return jsonResponse({ ok: true, sent, failed });
  } catch (error) {
    return errorResponse(error);
  }
});
