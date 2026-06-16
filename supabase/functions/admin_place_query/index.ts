import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

type Payload = {
  mode: "provinces" | "districts" | "places";
  province_slug?: string;
  province_id?: string;
  query?: string;
  limit?: number;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json()) as Payload;
    const service = getServiceClient();

    if (body.mode === "provinces") {
      const { data, error } = await service.from("provinces").select("id,name,slug,plate_no").order("plate_no");
      if (error) return jsonResponse({ error: error.message }, 500);
      return jsonResponse({ items: data ?? [] });
    }

    if (body.mode === "districts") {
      let provinceId = body.province_id ?? null;
      if (!provinceId && body.province_slug) {
        const province = await service.from("provinces").select("id").eq("slug", body.province_slug).maybeSingle();
        provinceId = (province.data?.id as string | undefined) ?? null;
      }
      if (!provinceId) return jsonResponse({ error: "province required" }, 400);

      const { data, error } = await service
        .from("districts")
        .select("id,name,slug,province_id")
        .eq("province_id", provinceId)
        .order("name");
      if (error) return jsonResponse({ error: error.message }, 500);
      return jsonResponse({ items: data ?? [] });
    }

    const limit = Math.max(1, Math.min(body.limit ?? 200, 500));
    let q = service
      .from("places_clean_with_coords")
      .select("id,province_id,district_id,name,slug,category,short_summary,best_time,duration_min,tags,popularity_score,lat,lng,app_rating,rating_count")
      .order("popularity_score", { ascending: false })
      .limit(limit);

    if (body.province_slug) {
      const province = await service.from("provinces").select("id").eq("slug", body.province_slug).maybeSingle();
      if (province.data?.id) q = q.eq("province_id", province.data.id);
    }

    if (body.query && body.query.trim()) {
      // Escape LIKE special characters to prevent wildcard injection
      const s = body.query.trim().slice(0, 100).replace(/[%_\\]/g, "\\$&");
      q = q.or(`name.ilike.%${s}%,slug.ilike.%${s}%`);
    }

    const { data, error } = await q;
    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({ items: data ?? [] });
  } catch (error) {
    return errorResponse(error);
  }
});
