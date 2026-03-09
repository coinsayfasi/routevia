import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

type Coord = { lat: number; lng: number };
type Payload = {
  trip_day_id?: string;
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
      }).filter((c) => Number.isFinite(c.lat) && Number.isFinite(c.lng));
    } else {
      coords = (body.coords ?? []).filter((c) => Number.isFinite(c.lat) && Number.isFinite(c.lng));
    }

    if (coords.length < 2) {
      return jsonResponse({ mode: "straight", points: coords });
    }

    const profile = body.profile ?? "driving";
    const osrmBase = Deno.env.get("OSRM_BASE_URL") ?? "http://localhost:5000";
    const path = coords.map((c) => `${c.lng},${c.lat}`).join(";");
    const url = `${osrmBase}/route/v1/${profile}/${path}?overview=full&geometries=geojson`;

    const resp = await fetch(url, { method: "GET" });
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
