// Pure decision function: both arguments must come from authenticated server queries.
export function hasActivePro(role: unknown, entitlements: { entitlement_key?: unknown; expires_at?: unknown }[], now = Date.now()): boolean {
  if (role === 'admin') return true;
  return entitlements.some((e) => e.entitlement_key === 'routevia_pro' &&
    typeof e.expires_at === 'string' && Date.parse(e.expires_at) > now);
}
