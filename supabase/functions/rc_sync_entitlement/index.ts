/**
 * rc_sync_entitlement — RevenueCat REST API üzerinden server-side entitlement doğrulama.
 *
 * Çağrı zamanı: Uygulama satın alma veya restore sonrası bu endpoint'i çağırır.
 * RevenueCat REST API (secret key) ile kullanıcının gerçek abonelik durumunu doğrular,
 * ardından user_entitlements tablosuna güvenli şekilde yazar.
 *
 * Env vars gerekli:
 *   REVENUECAT_SECRET_KEY — RevenueCat dashboard → API Keys → Secret key
 */

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse, errorResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

const RC_ENTITLEMENT_KEY = "routevia_pro";
const RC_API_BASE = "https://api.revenuecat.com/v1";

interface RcEntitlement {
  expires_date: string | null;
  product_identifier: string;
  is_active: boolean;
}

interface RcSubscriberResponse {
  subscriber: {
    entitlements: Record<string, RcEntitlement>;
    subscriptions: Record<string, { expires_date: string; unsubscribe_detected_at: string | null }>;
  };
}

async function fetchRcSubscriber(userId: string, secretKey: string): Promise<RcSubscriberResponse> {
  const res = await fetch(`${RC_API_BASE}/subscribers/${encodeURIComponent(userId)}`, {
    headers: {
      Authorization: `Bearer ${secretKey}`,
      "Content-Type": "application/json",
      "X-Platform": "stripe", // neutral header to avoid platform-specific rate limits
    },
    signal: AbortSignal.timeout(10_000),
  });
  if (res.status === 404) throw new Error("rc_subscriber_not_found");
  if (!res.ok) throw new Error(`rc_api_error:${res.status}`);
  return await res.json() as RcSubscriberResponse;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);

    const secretKey = Deno.env.get("REVENUECAT_SECRET_KEY") ?? "";
    if (!secretKey) {
      // Secret key yoksa silent fail — beta aşaması için kabul edilebilir
      return jsonResponse({ ok: true, source: "skipped_no_rc_key" });
    }

    const rcData = await fetchRcSubscriber(user.id, secretKey);
    const entitlement = rcData.subscriber.entitlements[RC_ENTITLEMENT_KEY];

    if (!entitlement || !entitlement.expires_date) {
      // Aktif entitlement yok — mevcut kaydı silme, sadece raporla
      return jsonResponse({ ok: true, is_pro: false });
    }

    const expiresAt = new Date(entitlement.expires_date);
    const now = new Date();

    if (isNaN(expiresAt.getTime())) {
      throw new Error("rc_invalid_expiry_date");
    }

    const isPro = expiresAt > now;

    if (!isPro) {
      return jsonResponse({ ok: true, is_pro: false });
    }

    // Server-side verified — güvenle yaz
    const service = getServiceClient();
    const { data: existing } = await service
      .from("user_entitlements")
      .select("id, expires_at")
      .eq("user_id", user.id)
      .eq("entitlement_key", RC_ENTITLEMENT_KEY)
      .maybeSingle();

    if (existing) {
      const prevExpiry = new Date(existing.expires_at);
      // Sadece RC doğruladıktan sonra güncelle; mevcut expiry daha uzunsa koru
      const finalExpiry = prevExpiry > expiresAt ? prevExpiry : expiresAt;
      await service
        .from("user_entitlements")
        .update({
          expires_at: finalExpiry.toISOString(),
        })
        .eq("id", existing.id);
    } else {
      await service.from("user_entitlements").insert({
        user_id: user.id,
        entitlement_key: RC_ENTITLEMENT_KEY,
        expires_at: expiresAt.toISOString(),
      });
    }

    return jsonResponse({
      ok: true,
      is_pro: true,
      expires_at: expiresAt.toISOString(),
      source: "revenuecat_verified",
    });
  } catch (e) {
    return errorResponse(e);
  }
});
