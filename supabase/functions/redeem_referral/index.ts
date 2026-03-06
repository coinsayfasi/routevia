import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = await req.json().catch(() => ({}));
    const code = String(body.code ?? "").trim().toUpperCase();
    if (!code || code.length < 6) return jsonResponse({ error: "Kod geçersiz" }, 400);

    const service = getServiceClient();

    const referrerProfile = await service
      .from("profiles")
      .select("id,referral_code")
      .eq("referral_code", code)
      .maybeSingle();

    if (!referrerProfile.data?.id) return jsonResponse({ error: "Kod bulunamadı" }, 404);
    if (String(referrerProfile.data.id) === user.id) return jsonResponse({ error: "Kendi kodunu kullanamazsın" }, 400);

    const existing = await service
      .from("referrals")
      .select("id,referee_user_id")
      .eq("referee_user_id", user.id)
      .maybeSingle();

    if (existing.data?.id) {
      return jsonResponse({ ok: true, already_redeemed: true });
    }

    const insertReferral = await service
      .from("referrals")
      .insert({
        referrer_user_id: referrerProfile.data.id,
        referee_user_id: user.id,
        code,
      })
      .select("id")
      .single();

    if (insertReferral.error) return jsonResponse({ error: insertReferral.error.message }, 500);

    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
    await service.from("user_entitlements").insert([
      {
        user_id: user.id,
        entitlement_key: "pro_preview_7d",
        expires_at: expiresAt,
      },
      {
        user_id: referrerProfile.data.id,
        entitlement_key: "pro_preview_7d",
        expires_at: expiresAt,
      },
    ]);

    await service.from("app_events").insert([
      { user_id: user.id, event_name: "referral_redeemed", payload: { code } },
      { user_id: referrerProfile.data.id, event_name: "referral_redeemed", payload: { code, as: "referrer" } },
    ]);

    return jsonResponse({ ok: true, entitlement: "pro_preview_7d", expires_at: expiresAt });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
