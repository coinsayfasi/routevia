import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdmin, requireUser } from "../_shared/client.ts";

type PlaceInput = {
  id?: string;
  province_slug: string;
  district_slug?: string | null;
  name: string;
  slug: string;
  category: "museum" | "historical" | "nature" | "beach" | "viewpoint" | "market" | "cafe" | "food" | "activity";
  lat: number;
  lng: number;
  short_summary: string;
  best_time: "morning" | "day" | "sunset" | "night";
  duration_min: number;
  tags: string[];
  popularity_score: number;
  history_bullets?: string[];
  eat_drink_bullets?: string[];
  tips_bullets?: string[];
  media_paths?: string[];
};

function assertInput(input: PlaceInput) {
  if (!input.province_slug || !input.name || !input.slug) throw new Error("province_slug,name,slug required");
  if (!Number.isFinite(input.lat) || !Number.isFinite(input.lng)) throw new Error("lat/lng invalid");
  if (input.short_summary.length > 160) throw new Error("short_summary > 160");
  if (input.duration_min < 15 || input.duration_min > 240) throw new Error("duration_min out of range");
  if ((input.history_bullets ?? []).length > 3) throw new Error("history_bullets max 3");
  if ((input.eat_drink_bullets ?? []).length > 3) throw new Error("eat_drink_bullets max 3");
  if ((input.tips_bullets ?? []).length > 4) throw new Error("tips_bullets max 4");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    await requireAdmin(user.id);

    const body = (await req.json()) as PlaceInput;
    assertInput(body);

    const service = getServiceClient();

    const province = await service.from("provinces").select("id").eq("slug", body.province_slug).single();
    if (province.error || !province.data?.id) throw new Error("province_not_found");

    let districtId: string | null = null;
    if (body.district_slug && body.district_slug.trim()) {
      const district = await service
        .from("districts")
        .select("id")
        .eq("province_id", province.data.id)
        .eq("slug", body.district_slug)
        .maybeSingle();
      districtId = (district.data?.id as string | undefined) ?? null;
    }

    const placeRecord = {
      id: body.id,
      province_id: province.data.id,
      district_id: districtId,
      name: body.name.trim(),
      slug: body.slug.trim(),
      category: body.category,
      geog: `SRID=4326;POINT(${body.lng} ${body.lat})`,
      short_summary: body.short_summary.trim(),
      best_time: body.best_time,
      duration_min: body.duration_min,
      tags: body.tags,
      popularity_score: body.popularity_score,
    };

    const upsert = await service
      .from("places_clean")
      .upsert(placeRecord, { onConflict: "province_id,slug" })
      .select("id")
      .single();
    if (upsert.error || !upsert.data?.id) throw new Error(upsert.error?.message ?? "upsert_failed");

    const placeId = String(upsert.data.id);

    const details = {
      place_id: placeId,
      history_bullets: body.history_bullets ?? [],
      eat_drink_bullets: body.eat_drink_bullets ?? [],
      tips_bullets: body.tips_bullets ?? [],
    };
    const detailsRes = await service.from("place_details_clean").upsert(details);
    if (detailsRes.error) throw new Error(detailsRes.error.message);

    const mediaPaths = (body.media_paths ?? []).map((m) => m.trim()).filter((m) => m.length > 0);
    for (let i = 0; i < mediaPaths.length; i += 1) {
      const storagePath = mediaPaths[i];
      const existing = await service
        .from("place_media_clean")
        .select("id")
        .eq("place_id", placeId)
        .eq("storage_path", storagePath)
        .maybeSingle();
      if (!existing.data?.id) {
        await service.from("place_media_clean").insert({
          place_id: placeId,
          storage_path: storagePath,
          source: "curated",
          sort_order: i,
        });
      }
    }

    return jsonResponse({ place_id: placeId });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
