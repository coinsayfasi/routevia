import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";
import { sendFirebasePush } from "../_shared/firebase.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

type Payload = {
  user_id?: string;
  content_kind?: "review" | "photo";
  place_name?: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrService(authHeader);

    const body = (await req.json()) as Payload;
    const userId = String(body.user_id ?? "").trim();
    const contentKind = body.content_kind === "photo" ? "photo" : "review";
    const placeName = String(body.place_name ?? "").trim();
    if (!userId) return jsonResponse({ error: "user_id is required" }, 400);
    if (
      !Deno.env.get("FIREBASE_PROJECT_ID") ||
      !Deno.env.get("FIREBASE_CLIENT_EMAIL") ||
      !Deno.env.get("FIREBASE_PRIVATE_KEY")
    ) {
      return jsonResponse({ ok: true, skipped: "firebase_secrets_missing" });
    }

    const service = getServiceClient();
    const { data: profile, error: profileError } = await service
      .from("profiles")
      .select("allow_notifications")
      .eq("id", userId)
      .maybeSingle();
    if (profileError) return jsonResponse({ error: profileError.message }, 500);
    if (profile != null && profile.allow_notifications === false) {
      return jsonResponse({ ok: true, skipped: "notifications_disabled" });
    }

    const { data: tokens, error: tokenError } = await service
      .from("user_push_tokens")
      .select("id,token,platform")
      .eq("user_id", userId)
      .eq("enabled", true)
      .order("updated_at", { ascending: false })
      .limit(5);
    if (tokenError) return jsonResponse({ error: tokenError.message }, 500);
    if (!tokens || tokens.length == 0) {
      return jsonResponse({ ok: true, skipped: "no_push_tokens" });
    }

    const title = contentKind === "photo" ? "Fotografin yayinda!" : "Yorumun yayinda!";
    const bodyText = !placeName
      ? "Icerigin moderasyondan gecti ve artik gorunuyor."
      : `${placeName} icin gonderdigin icerik artik yayinda.`;

    const failures: string[] = [];
    let sent = 0;
    for (const row of tokens) {
      try {
        await sendFirebasePush({
          token: String(row.token),
          title,
          body: bodyText,
          data: {
            type: "content_approved",
            content_kind: contentKind,
            place_name: placeName,
          },
        });
        sent += 1;
      } catch (error) {
        failures.push(error instanceof Error ? error.message : String(error));
      }
    }

    return jsonResponse({
      ok: true,
      sent,
      failed: failures.length,
      failures,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
