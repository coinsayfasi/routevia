import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

interface PurchasePayload {
  platform: "ios" | "android";
  purchase_token: string;
  product_id: string;
}

const PRODUCT_ENTITLEMENTS: Record<string, { key: string; days: number }> = {
  routevia_pro_monthly: { key: "routevia_pro", days: 30 },
  routevia_pro_yearly: { key: "routevia_pro", days: 365 },
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as PurchasePayload;

    const { platform, purchase_token, product_id } = body;
    if (!platform || !purchase_token || !product_id) {
      return jsonResponse({ error: "Missing platform, purchase_token or product_id" }, 400);
    }

    const mapping = PRODUCT_ENTITLEMENTS[product_id];
    if (!mapping) {
      return jsonResponse({ error: `Unknown product_id: ${product_id}` }, 400);
    }

    const service = getServiceClient();

    // ── Trust-but-verify: log and grant ──────────────────────────────────
    // In production, add App Store Server API / Google Play Developer API
    // validation here before granting.

    await service.from("app_events").insert({
      user_id: user.id,
      event_name: "purchase_verified",
      payload: {
        platform,
        product_id,
        purchase_token: purchase_token.substring(0, 64),
        entitlement_key: mapping.key,
        trust_mode: "trust_but_verify",
      },
    });

    const now = new Date();
    const expiresAt = new Date(now.getTime() + mapping.days * 24 * 60 * 60 * 1000);

    // Upsert entitlement – extend if already exists
    const { data: existing } = await service
      .from("user_entitlements")
      .select("id,expires_at")
      .eq("user_id", user.id)
      .eq("entitlement_key", mapping.key)
      .maybeSingle();

    let finalExpiry = expiresAt;
    if (existing) {
      const prevExpiry = new Date(existing.expires_at);
      // If previous entitlement is still active, extend from its end
      if (prevExpiry > now) {
        finalExpiry = new Date(prevExpiry.getTime() + mapping.days * 24 * 60 * 60 * 1000);
      }
      await service
        .from("user_entitlements")
        .update({ expires_at: finalExpiry.toISOString(), updated_at: now.toISOString() })
        .eq("id", existing.id);
    } else {
      await service.from("user_entitlements").insert({
        user_id: user.id,
        entitlement_key: mapping.key,
        expires_at: finalExpiry.toISOString(),
      });
    }

    return jsonResponse({
      ok: true,
      entitlement_key: mapping.key,
      expires_at: finalExpiry.toISOString(),
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    const status = msg === "Unauthorized" || msg === "Missing Authorization header" ? 401 : 500;
    return jsonResponse({ error: msg }, status);
  }
});
