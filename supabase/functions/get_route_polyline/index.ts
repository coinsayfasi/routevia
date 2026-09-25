import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

import { hasActivePro } from "../_shared/pro_access.ts";
import { fetchRcProExpiry } from "../_shared/revenuecat.ts";

type Coord = { lat: number; lng: number };
type Payload = {
  trip_day_id?: string;
  matrix?: boolean;
  pro_feature?: "return_deadline";
  coords?: Coord[];
  profile?: "driving" | "walking" | "cycling";
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const body = (await req.json()) as Payload;
    let coords: Coord[] = [];
    const authHeader = req.headers.get("Authorization") ?? undefined;

    let proAuthorized = false;
    if (body.pro_feature !== undefined) {
      if (body.pro_feature !== "return_deadline" || body.matrix !== true) {
        return jsonResponse({ error: "invalid_pro_feature" }, 400);
      }
      let user;
      try { user = await requireUser(authHeader); }
      catch { return jsonResponse({ error: "unauthorized" }, 401); }
      const service = getServiceClient();
      const [profile, entitlements] = await Promise.all([
        service.from("profiles").select("role").eq("id", user.id).maybeSingle(),
        service.from("user_entitlements").select("entitlement_key,expires_at").eq("user_id", user.id),
      ]);
      if (profile.error || entitlements.error) return jsonResponse({ error: "entitlement_unavailable" }, 503);
      if (!hasActivePro(profile.data?.role, entitlements.data ?? [])) {
        // DB yalnızca satın alma anında senkronlanıyor; yenilenmiş abonelikler için RevenueCat'e danış.
        let rcExpiry: string | null;
        try { rcExpiry = await fetchRcProExpiry(user.id); }
        catch { return jsonResponse({ error: "entitlement_unavailable" }, 503); }
        if (!rcExpiry) return jsonResponse({ error: "pro_required" }, 403);
        await service.from("user_entitlements").delete()
          .eq("user_id", user.id).eq("entitlement_key", "routevia_pro");
        await service.from("user_entitlements").insert({
          user_id: user.id, entitlement_key: "routevia_pro", expires_at: rcExpiry,
        });
      }
      proAuthorized = true;
    }
    const matrixResponse = (data: Record<string, unknown>) => jsonResponse({ ...data, pro_authorized: proAuthorized });

    if (body.trip_day_id) {
      if (!/^[0-9a-fA-F-]{36}$/.test(body.trip_day_id)) {
        return jsonResponse({ error: "trip_day_id_invalid" }, 400);
      }

      if (!authHeader) {
        return jsonResponse({ error: "unauthorized" }, 401);
      }

      let user: { id: string };
      try {
        user = await requireUser(authHeader) as { id: string };
      } catch {
        return jsonResponse({ error: "unauthorized" }, 401);
      }

      const service = getServiceClient();

      const owner = await service
        .from("trip_days_clean")
        .select("id,trip:trips_clean!inner(user_id)")
        .eq("id", body.trip_day_id)
        .maybeSingle();

      const trip = (owner.data as Record<string, unknown> | null)?.trip as Record<string, unknown> | null;
      if (owner.error || !owner.data || String(trip?.user_id ?? "") !== user.id) {
        return jsonResponse({ error: "forbidden" }, 403);
      }

      const rows = await service
        .from("trip_stops_clean")
        .select("order_index, place:places_clean!inner(geog)")
        .eq("trip_day_id", body.trip_day_id)
        .order("order_index", { ascending: true });

      if (rows.error) return jsonResponse({ error: rows.error.message }, 500);
      coords = ((rows.data as Record<string, unknown>[] | null) ?? []).map((r) => {
        const place = r.place as Record<string, unknown>;
        const geog = String(place.geog ?? "");
        const m = /POINT\(([-0-9.]+) ([-0-9.]+)\)/.exec(geog);
        return { lat: Number(m?.[2] ?? 0), lng: Number(m?.[1] ?? 0) };
      }).filter((c) => Number.isFinite(c.lat) && Number.isFinite(c.lng) && c.lat >= -90 && c.lat <= 90 && c.lng >= -180 && c.lng <= 180);
    } else {
      coords = (body.coords ?? []).filter((c) =>
  Number.isFinite(c.lat) && Number.isFinite(c.lng) &&
  c.lat >= -90 && c.lat <= 90 && c.lng >= -180 && c.lng <= 180
);
    }

    if (coords.length < 2) {
      return jsonResponse({ mode: "straight", points: coords });
    }

    if (body.matrix) {
      if (coords.length > 25 || coords.length !== body.coords?.length) {
        return jsonResponse({ error: "invalid_coordinates" }, 400);
      }
      const profile = body.profile ?? "driving";
      // OSRM profiles depend on the dataset loaded into each server.
      // Never send walking/cycling requests to a driving-only dataset.
      const envKey = profile === "walking" ? "OSRM_WALKING_BASE_URL"
        : profile === "cycling" ? "OSRM_CYCLING_BASE_URL" : "OSRM_BASE_URL";
      if (!["walking", "cycling", "driving"].includes(profile)) {
        return jsonResponse({ error: "invalid_profile" }, 400);
      }
      const base = Deno.env.get(envKey);
      if (!base) return matrixResponse({ mode: "unavailable" });
      try {
        const path = coords.map((c) => `${c.lng},${c.lat}`).join(";");
        const response = await fetch(`${base.replace(/\/$/, "")}/table/v1/${profile}/${path}?annotations=duration`, {
          signal: AbortSignal.timeout(8_000),
        });
        if (!response.ok) return matrixResponse({ mode: "unavailable" });
        const data = await response.json();
        const durations = data.durations;
        if (data.code !== "Ok" || !Array.isArray(durations) || durations.length !== coords.length ||
            !durations.every((row: unknown) => Array.isArray(row) && row.length === coords.length &&
              row.every((value: unknown) => value === null || (typeof value === "number" && Number.isFinite(value) && value >= 0)))) {
          return matrixResponse({ mode: "unavailable" });
        }
        return matrixResponse({ mode: "osrm", durations });
      } catch {
        return matrixResponse({ mode: "unavailable" });
      }
    }

    const profile = body.profile ?? "driving";
    const osrmBase = Deno.env.get("OSRM_BASE_URL");
    // Yol servisi yapılandırılmamış/erişilemezse 500 yerine açıkça işaretli düz çizgi.
    if (!osrmBase) return jsonResponse({ mode: "straight", points: coords, fallback: true });
    const path = coords.map((c) => `${c.lng},${c.lat}`).join(";");
    const url = `${osrmBase.replace(/\/$/, "")}/route/v1/${profile}/${path}?overview=full&geometries=geojson`;

    let resp: Response;
    try {
      resp = await fetch(url, { method: "GET", signal: AbortSignal.timeout(8_000) });
    } catch {
      return jsonResponse({ mode: "straight", points: coords, fallback: true });
    }
    if (!resp.ok) {
      return jsonResponse({ mode: "straight", points: coords, fallback: true });
    }
    const data = await resp.json();
    const route = data?.routes?.[0]?.geometry?.coordinates as [number, number][] | undefined;
    if (!route || route.length === 0) {
      return jsonResponse({ mode: "straight", points: coords, fallback: true });
    }

    return jsonResponse({
      mode: "osrm",
      points: route.map((p) => ({ lat: p[1], lng: p[0] })),
      distance_m: Number(data?.routes?.[0]?.distance ?? 0),
      duration_s: Number(data?.routes?.[0]?.duration ?? 0),
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
