import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const service = getServiceClient();

    // Checkins (new community table)
    const { count: checkins } = await service
      .from("place_checkins")
      .select("*", { count: "exact", head: true })
      .eq("user_id", user.id);

    // Favorites (poi_signals still used for favorites)
    const { count: favorites } = await service
      .from("poi_signals")
      .select("*", { count: "exact", head: true })
      .eq("user_id", user.id)
      .eq("type", "favorite");

    // Reviews (new community table)
    const { count: reviews } = await service
      .from("place_reviews")
      .select("*", { count: "exact", head: true })
      .eq("user_id", user.id);

    // Trips
    const { count: trips } = await service
      .from("trips_clean")
      .select("*", { count: "exact", head: true })
      .eq("user_id", user.id);

    // Cities visited + category breakdown from checkin POIs
    const { data: checkinRows } = await service
      .from("place_checkins")
      .select("place_id")
      .eq("user_id", user.id)
      .limit(500);

    const poiIds = (checkinRows ?? []).map((r: { place_id: string }) => r.place_id);

    let citiesVisited = 0;
    let topCity: string | null = null;
    const categoryBreakdown: Record<string, number> = {};

    if (poiIds.length > 0) {
      const { data: pois } = await service
        .from("pois")
        .select("city,category")
        .in_("id", poiIds);

      const cityCounts: Record<string, number> = {};
      for (const poi of pois ?? []) {
        const city = (poi as { city?: string; category?: string }).city;
        const cat = (poi as { city?: string; category?: string }).category;
        if (city) cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        if (cat) categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0) + 1;
      }
      citiesVisited = Object.keys(cityCounts).length;

      let maxCount = 0;
      for (const [city, count] of Object.entries(cityCounts)) {
        if (count > maxCount) {
          maxCount = count;
          topCity = city;
        }
      }
    }

    return jsonResponse({
      checkins: checkins ?? 0,
      favorites: favorites ?? 0,
      reviews: reviews ?? 0,
      trips: trips ?? 0,
      cities_visited: citiesVisited,
      top_city: topCity,
      category_breakdown: categoryBreakdown,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
