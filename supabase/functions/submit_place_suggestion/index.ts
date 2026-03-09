import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

type Payload = {
  province_slug: string;
  district_slug?: string;
  suggested_name: string;
  suggested_category: string;
  suggested_tags?: string[];
  short_note: string;
  lat?: number;
  lng?: number;
  source_url?: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const body = (await req.json()) as Payload;

    if (!body.province_slug || !body.suggested_name || !body.suggested_category) {
      return jsonResponse({ error: "province_slug, suggested_name, suggested_category required" }, 400);
    }
    if (!body.short_note || body.short_note.length > 240) {
      return jsonResponse({ error: "short_note required and <= 240" }, 400);
    }

    const service = getServiceClient();

    const { data: province, error: provinceError } = await service
      .from("provinces")
      .select("id")
      .eq("slug", body.province_slug)
      .single();
    if (provinceError || !province) return jsonResponse({ error: "province not found" }, 404);

    let districtId: string | null = null;
    if (body.district_slug && body.district_slug.trim().length > 0) {
      const { data: district } = await service
        .from("districts")
        .select("id")
        .eq("province_id", province.id)
        .eq("slug", body.district_slug)
        .maybeSingle();
      districtId = (district?.id as string | undefined) ?? null;
    }

    const payload = {
      user_id: user.id,
      province_id: province.id,
      district_id: districtId,
      suggested_name: body.suggested_name.trim(),
      suggested_category: body.suggested_category,
      suggested_tags: (body.suggested_tags ?? []).slice(0, 12),
      short_note: body.short_note.trim(),
      lat: Number.isFinite(body.lat) ? body.lat : null,
      lng: Number.isFinite(body.lng) ? body.lng : null,
      source_url: body.source_url?.trim() || null,
      status: "pending",
    };

    const { data, error } = await service
      .from("place_suggestions")
      .insert(payload)
      .select("id,status,created_at")
      .single();

    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({ suggestion: data, message: "Suggestion submitted" });
  } catch (error) {
    return errorResponse(error);
  }
});
