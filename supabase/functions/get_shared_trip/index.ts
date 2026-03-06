import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient } from "../_shared/client.ts";

function mediaUrl(path: string | null): string | null {
  if (!path) return null;
  return `${Deno.env.get("SUPABASE_URL")}/storage/v1/object/public/${path}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const token = req.method === "GET"
      ? new URL(req.url).searchParams.get("token")
      : ((await req.json()) as { token?: string }).token;

    if (!token) return jsonResponse({ error: "token is required" }, 400);

    const service = getServiceClient();

    const share = await service
      .from("trip_shares_clean")
      .select("trip_id,is_active")
      .eq("share_token", token)
      .eq("is_active", true)
      .maybeSingle();

    if (share.error || !share.data?.trip_id) return jsonResponse({ error: "shared_trip_not_found" }, 404);

    const tripId = String(share.data.trip_id);

    const trip = await service
      .from("trips_clean")
      .select("id,province_id,days,transport_mode,pace,persona_mode,preferences,created_at")
      .eq("id", tripId)
      .maybeSingle();

    if (trip.error || !trip.data) return jsonResponse({ error: "trip_not_found" }, 404);

    const province = await service
      .from("provinces")
      .select("id,name,slug")
      .eq("id", trip.data.province_id)
      .maybeSingle();

    const dayRows = await service
      .from("trip_days_clean")
      .select("id,day_number")
      .eq("trip_id", tripId)
      .order("day_number", { ascending: true });

    const days: Array<Record<string, unknown>> = [];
    for (const d of ((dayRows.data as Record<string, unknown>[] | null) ?? [])) {
      const dayId = String(d.id);
      const stopsRes = await service
        .from("trip_stops_clean")
        .select("order_index,arrival_time,duration_min,transport_mode,place:places_clean!inner(id,name,slug,category,short_summary,best_time,duration_min,tags,geog)")
        .eq("trip_day_id", dayId)
        .order("order_index", { ascending: true });

      const stops = ((stopsRes.data as Record<string, unknown>[] | null) ?? []).map((s) => {
        const place = s.place as Record<string, unknown>;
        const geogText = String(place.geog ?? "");
        const m = /POINT\(([-0-9.]+) ([-0-9.]+)\)/.exec(geogText);
        const lng = Number(m?.[1] ?? 0);
        const lat = Number(m?.[2] ?? 0);
        return {
          order_index: Number(s.order_index ?? 0),
          arrival_time: String(s.arrival_time ?? "10:00:00"),
          duration_min: Number(s.duration_min ?? 60),
          transport_mode: String(s.transport_mode ?? "car"),
          place: {
            id: String(place.id),
            name: String(place.name ?? ""),
            slug: String(place.slug ?? ""),
            category: String(place.category ?? "activity"),
            short_summary: String(place.short_summary ?? ""),
            best_time: String(place.best_time ?? "day"),
            duration_min: Number(place.duration_min ?? 60),
            tags: (place.tags as string[] | null) ?? [],
            lat,
            lng,
            media: [],
          },
        };
      });

      // attach first media per place
      for (const stop of stops) {
        const placeId = String((stop.place as Record<string, unknown>).id);
        const media = await service
          .from("place_media_clean")
          .select("storage_path,sort_order")
          .eq("place_id", placeId)
          .order("sort_order", { ascending: true })
          .limit(1);
        const first = ((media.data as Record<string, unknown>[] | null) ?? [])[0];
        if (first?.storage_path) {
          (stop.place as Record<string, unknown>).media = [{
            storage_path: String(first.storage_path),
            sort_order: Number(first.sort_order ?? 0),
            public_url: mediaUrl(String(first.storage_path)),
          }];
        }
      }

      days.push({ day_number: Number(d.day_number), stops });
    }

    return jsonResponse({
      trip_id: String(trip.data.id),
      created_at: trip.data.created_at,
      province: {
        id: province.data?.id,
        name: province.data?.name,
        slug: province.data?.slug,
      },
      days: Number(trip.data.days),
      transport_mode: String(trip.data.transport_mode),
      pace: String(trip.data.pace),
      persona_mode: String(trip.data.persona_mode),
      preferences: (trip.data.preferences as string[] | null) ?? [],
      days_plan: days,
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
