import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
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

type VerificationResult = {
  expiresAt: string;
  storePayload: Record<string, unknown>;
};

type GoogleServiceAccount = {
  client_email: string;
  private_key: string;
  token_uri?: string;
};

async function getGooglePlayAccessToken(): Promise<string> {
  const raw = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON") ?? "";
  if (!raw) {
    throw new Error("billing_config_missing_google_play_service_account");
  }
  const account = JSON.parse(raw) as GoogleServiceAccount;
  if (!account.client_email || !account.private_key) {
    throw new Error("billing_config_invalid_google_play_service_account");
  }
  const tokenUri = account.token_uri ?? "https://oauth2.googleapis.com/token";
  const now = Math.floor(Date.now() / 1000);
  const header = textToBase64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = textToBase64Url(JSON.stringify({
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: tokenUri,
    exp: now + 3600,
    iat: now,
  }));
  const signingInput = `${header}.${claim}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput),
  );
  const assertion = `${signingInput}.${base64UrlEncodeBytes(new Uint8Array(signature))}`;
  const res = await fetch(tokenUri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
    signal: AbortSignal.timeout(15_000),
  });
  if (!res.ok) {
    throw new Error(`google_play_oauth_failed:${res.status}`);
  }
  const json = await res.json();
  const accessToken = String(json.access_token ?? "");
  if (!accessToken) {
    throw new Error("google_play_access_token_missing");
  }
  return accessToken;
}

async function verifyGooglePlayPurchase(
  purchaseToken: string,
  productId: string,
): Promise<VerificationResult> {
  const packageName = Deno.env.get("GOOGLE_PLAY_PACKAGE_NAME") ?? "com.yunusgunes.routevia";
  const accessToken = await getGooglePlayAccessToken();
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}` +
    `/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
    signal: AbortSignal.timeout(15_000),
  });
  if (!res.ok) {
    throw new Error(`google_play_verify_failed:${res.status}`);
  }
  const json = await res.json();
  const subscriptionState = String(json.subscriptionState ?? "");
  const lineItems = Array.isArray(json.lineItems) ? json.lineItems as Record<string, unknown>[] : [];
  const lineItem = lineItems.find((item) => String(item.productId ?? "") === productId);
  if (!lineItem) {
    throw new Error("google_play_product_mismatch");
  }
  const expiry = String(lineItem.expiryTime ?? "");
  if (!expiry) {
    throw new Error("google_play_expiry_missing");
  }
  const expiryDate = new Date(expiry);
  if (Number.isNaN(expiryDate.getTime())) {
    throw new Error("google_play_expiry_invalid");
  }
  const activeStates = new Set([
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    "SUBSCRIPTION_STATE_ON_HOLD",
  ]);
  if (!activeStates.has(subscriptionState) || expiryDate.getTime() <= Date.now()) {
    throw new Error("google_play_subscription_inactive");
  }
  const acknowledgementState = String(json.acknowledgementState ?? "");
  if (acknowledgementState === "ACKNOWLEDGEMENT_STATE_PENDING") {
    try {
      await fetch(
        `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}` +
          `/purchases/subscriptions/${encodeURIComponent(productId)}/tokens/${encodeURIComponent(purchaseToken)}:acknowledge`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ developerPayload: "routevia-server-ack" }),
        },
      );
    } catch (_) {
      // Best effort only.
    }
  }
  return {
    expiresAt: expiryDate.toISOString(),
    storePayload: {
      source: "google_play",
      package_name: packageName,
      subscription_state: subscriptionState,
      acknowledgement_state: acknowledgementState,
      latest_order_id: json.latestOrderId ?? null,
    },
  };
}

// ---------------------------------------------------------------------------
// Apple: App Store Server API v2 (öncelikli) + verifyReceipt (fallback)
//
// Öncelikli: App Store Server API v2 — JWS/JWT tabanlı, Apple'ın tavsiye ettiği yol.
// Gerekli env vars (App Store Connect → Keys):
//   APPLE_KEY_ID        — "2X9R4HXF34" formatında
//   APPLE_ISSUER_ID     — UUID formatında
//   APPLE_PRIVATE_KEY   — -----BEGIN PRIVATE KEY----- bloğu (P8 dosyası içeriği)
//
// Fallback: verifyReceipt — Deprecated (Apple 2025'te sunset planlıyor).
// Gerekli env var: APPLE_SHARED_SECRET
// ---------------------------------------------------------------------------

function textToBase64Url(value: string): string {
  const encoded = new TextEncoder().encode(value);
  const binary = Array.from(encoded).map((b) => String.fromCharCode(b)).join("");
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function base64UrlEncodeBytes(bytes: Uint8Array): string {
  const binary = Array.from(bytes).map((b) => String.fromCharCode(b)).join("");
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const body = pem
    .replace(/-----BEGIN (?:EC )?PRIVATE KEY-----/g, "")
    .replace(/-----END (?:EC )?PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(body);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function buildAppleJwt(keyId: string, issuerId: string, privateKeyPem: string): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = textToBase64Url(JSON.stringify({ alg: "ES256", kid: keyId, typ: "JWT" }));
  const payload = textToBase64Url(JSON.stringify({
    iss: issuerId,
    iat: now,
    exp: now + 3600,
    aud: "appstoreconnect-v1",
  }));
  const signingInput = `${header}.${payload}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(privateKeyPem),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
  const sigBytes = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput),
  );
  return `${signingInput}.${base64UrlEncodeBytes(new Uint8Array(sigBytes))}`;
}

async function verifyApplePurchaseV2(
  transactionId: string,
  productId: string,
  bundleId: string,
): Promise<VerificationResult | null> {
  const keyId = Deno.env.get("APPLE_KEY_ID") ?? "";
  const issuerId = Deno.env.get("APPLE_ISSUER_ID") ?? "";
  const privateKey = Deno.env.get("APPLE_PRIVATE_KEY") ?? "";
  if (!keyId || !issuerId || !privateKey) return null; // env vars eksik — fallback

  const jwt = await buildAppleJwt(keyId, issuerId, privateKey);
  // Production endpoint önce dene
  for (const env of ["production", "sandbox"]) {
    const base = env === "production"
      ? "https://api.storekit.itunes.apple.com"
      : "https://api.storekit-sandbox.itunes.apple.com";
    const res = await fetch(
      `${base}/inApps/v1/subscriptions/${encodeURIComponent(transactionId)}`,
      { headers: { Authorization: `Bearer ${jwt}` }, signal: AbortSignal.timeout(15_000) },
    );
    if (res.status === 404) continue;
    if (!res.ok) throw new Error(`apple_v2_api_error:${res.status}`);
    const json = await res.json() as {
      data?: Array<{ lastTransactions?: Array<{ transactionId: string; expiresDate?: number; productId: string; status: number }> }>;
    };
    const items = json.data?.flatMap((g) => g.lastTransactions ?? []) ?? [];
    const match = items
      .filter((t) => t.productId === productId && t.status === 1)
      .sort((a, b) => (b.expiresDate ?? 0) - (a.expiresDate ?? 0))[0];
    if (!match?.expiresDate) continue;
    const expiryMs = match.expiresDate; // v2 API ms cinsinden döner
    if (expiryMs <= Date.now()) throw new Error("apple_subscription_inactive");
    return {
      expiresAt: new Date(expiryMs).toISOString(),
      storePayload: {
        source: env === "sandbox" ? "app_store_sandbox" : "app_store",
        bundle_id: bundleId,
        transaction_id: match.transactionId,
        api_version: "v2",
      },
    };
  }
  return null;
}

async function postAppleVerifyReceipt(
  url: string,
  receiptData: string,
  sharedSecret: string,
): Promise<Record<string, unknown>> {
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      "receipt-data": receiptData,
      password: sharedSecret,
      "exclude-old-transactions": true,
    }),
    signal: AbortSignal.timeout(15_000),
  });
  if (!res.ok) throw new Error(`apple_verify_http_failed:${res.status}`);
  return await res.json() as Record<string, unknown>;
}

async function verifyApplePurchase(
  receiptData: string,
  productId: string,
): Promise<VerificationResult> {
  const expectedBundleId = Deno.env.get("APPLE_BUNDLE_ID") ?? "com.yunusgunes.routevia";

  // Önce v2 API dene (transactionId olarak receiptData kullanılabiliyorsa)
  // Not: RevenueCat SDK purchase_token olarak transaction_id gönderebilir.
  // purchase_token 18-19 haneli sayısal string ise doğrudan v2'ye git.
  if (/^\d{15,20}$/.test(receiptData.trim())) {
    const v2Result = await verifyApplePurchaseV2(receiptData.trim(), productId, expectedBundleId);
    if (v2Result) return v2Result;
  }

  // Fallback: verifyReceipt (deprecated, hâlâ çalışıyor)
  const sharedSecret = Deno.env.get("APPLE_SHARED_SECRET") ?? "";
  if (!sharedSecret) throw new Error("billing_config_missing_apple_shared_secret");

  let usedSandbox = false;
  let json = await postAppleVerifyReceipt(
    "https://buy.itunes.apple.com/verifyReceipt",
    receiptData,
    sharedSecret,
  );
  const status = Number(json.status ?? -1);
  if (status === 21007) {
    usedSandbox = true;
    json = await postAppleVerifyReceipt(
      "https://sandbox.itunes.apple.com/verifyReceipt",
      receiptData,
      sharedSecret,
    );
  }
  const finalStatus = Number(json.status ?? -1);
  if (finalStatus !== 0) throw new Error(`apple_verify_failed:${finalStatus}`);

  const receipt = (json.receipt ?? {}) as Record<string, unknown>;
  const bundleId = String(receipt.bundle_id ?? "");
  if (bundleId && bundleId !== expectedBundleId) throw new Error("apple_bundle_mismatch");

  const candidates = [
    ...(Array.isArray(json.latest_receipt_info) ? json.latest_receipt_info as Record<string, unknown>[] : []),
    ...(Array.isArray(receipt.in_app) ? receipt.in_app as Record<string, unknown>[] : []),
  ].filter((entry) => String(entry.product_id ?? "") === productId);

  if (candidates.length === 0) throw new Error("apple_product_mismatch");

  candidates.sort((a, b) =>
    Number(b.expires_date_ms ?? b.purchase_date_ms ?? 0) -
    Number(a.expires_date_ms ?? a.purchase_date_ms ?? 0)
  );
  const latest = candidates[0];
  const expiryMs = Number(latest.expires_date_ms ?? latest.purchase_date_ms ?? 0);
  if (!Number.isFinite(expiryMs) || expiryMs <= Date.now()) throw new Error("apple_subscription_inactive");

  return {
    expiresAt: new Date(expiryMs).toISOString(),
    storePayload: {
      source: usedSandbox ? "app_store_sandbox" : "app_store",
      bundle_id: bundleId || expectedBundleId,
      original_transaction_id: latest.original_transaction_id ?? null,
      transaction_id: latest.transaction_id ?? null,
      api_version: "v1_legacy",
    },
  };
}

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

    if (!/^[a-z0-9_]+$/.test(product_id) || product_id.length > 60) {
      return jsonResponse({ error: "Invalid product_id" }, 400);
    }
    const mapping = PRODUCT_ENTITLEMENTS[product_id];
    if (!mapping) {
      return jsonResponse({ error: "Unknown product" }, 400);
    }

    const service = getServiceClient();
    const verification = platform === "android"
      ? await verifyGooglePlayPurchase(purchase_token, product_id)
      : await verifyApplePurchase(purchase_token, product_id);

    await service.from("app_events").insert({
      user_id: user.id,
      event_name: "purchase_verified",
      payload: {
        platform,
        product_id,
        purchase_token: purchase_token.substring(0, 64),
        entitlement_key: mapping.key,
        verification_source: verification.storePayload.source ?? platform,
        store_payload: verification.storePayload,
      },
    });

    const now = new Date();
    const storeExpiry = new Date(verification.expiresAt);
    if (Number.isNaN(storeExpiry.getTime())) {
      throw new Error("store_expiry_invalid");
    }

    // Upsert entitlement – extend if already exists
    const { data: existing } = await service
      .from("user_entitlements")
      .select("id,expires_at")
      .eq("user_id", user.id)
      .eq("entitlement_key", mapping.key)
      .maybeSingle();

    let finalExpiry = storeExpiry;
    if (existing) {
      const prevExpiry = new Date(existing.expires_at);
      if (prevExpiry > finalExpiry) finalExpiry = prevExpiry;
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
    return errorResponse(e);
  }
});
