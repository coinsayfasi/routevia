// RevenueCat REST (v1) ile sunucu tarafı entitlement doğrulaması.
// user_entitlements yalnızca satın alma/geri yükleme anında senkronlandığı için
// yenilemeler DB'ye yansımayabilir; Pro kapıları DB'de aktif kayıt yoksa buraya danışır.

const RC_API_BASE = "https://api.revenuecat.com/v1";
// Dashboard'da iki entitlement tanımlı (bkz. RevenueCat projesi): ikisi de Pro sayılır.
export const RC_PRO_ENTITLEMENTS = ["routevia_pro", "Routevia Pro"];
const LIFETIME_EXPIRY = "2099-12-31T00:00:00.000Z";

type RcEntitlement = { expires_date: string | null; grace_period_expires_date?: string | null };

/** Aktif Pro'nun bitiş tarihini (ISO) döndürür; aktif Pro yoksa null. RC erişilemezse hata fırlatır. */
export async function fetchRcProExpiry(userId: string, now = Date.now()): Promise<string | null> {
  const secretKey = Deno.env.get("REVENUECAT_SECRET_KEY") ?? "";
  if (!secretKey) throw new Error("rc_key_missing");
  const res = await fetch(`${RC_API_BASE}/subscribers/${encodeURIComponent(userId)}`, {
    headers: { Authorization: `Bearer ${secretKey}`, "Content-Type": "application/json" },
    signal: AbortSignal.timeout(8_000),
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`rc_api_error:${res.status}`);
  const data = await res.json();
  const entitlements: Record<string, RcEntitlement> = data?.subscriber?.entitlements ?? {};
  let best: string | null = null;
  for (const key of RC_PRO_ENTITLEMENTS) {
    const e = entitlements[key];
    if (!e) continue;
    const exp = e.expires_date === null ? LIFETIME_EXPIRY : (e.grace_period_expires_date ?? e.expires_date);
    if (typeof exp !== "string" || !(Date.parse(exp) > now)) continue;
    if (best === null || Date.parse(exp) > Date.parse(best)) best = exp;
  }
  return best;
}
