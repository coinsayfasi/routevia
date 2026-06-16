import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getServiceClient } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

function toInt(value: string | null, fallback: number) {
  const parsed = Number.parseInt(value ?? "", 10);
  if (!Number.isFinite(parsed)) return fallback;
  return parsed;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "GET" && req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const url = new URL(req.url);
    const body = req.method === "POST"
      ? await req.json().catch(() => ({}))
      : {};

    const province = String(
      url.searchParams.get("province") ??
        (body as Record<string, unknown>).province ??
        "",
    ).trim();
    const provinceSlug = String(
      url.searchParams.get("province_slug") ??
        (body as Record<string, unknown>).province_slug ??
        "",
    ).trim();
    const month = toInt(
      url.searchParams.get("month") ??
        String((body as Record<string, unknown>).month ?? ""),
      new Date().getUTCMonth() + 1,
    );
    const limit = Math.min(
      100,
      Math.max(
        1,
        toInt(
          url.searchParams.get("limit") ??
            String((body as Record<string, unknown>).limit ?? ""),
          24,
        ),
      ),
    );

    const service = getServiceClient();
    let query = service
      .from("events")
      .select(
        "id,province_id,province_name,district,name,slug,description,month_start,month_end,category,is_recurring,tags,lat,lng,image_url,source_url,is_active",
      )
      .eq("is_active", true)
      .lte("month_start", month)
      .gte("month_end", month)
      .order("month_start")
      .order("name")
      .limit(limit);

    if (provinceSlug) {
      const { data: provinceRow, error: provinceError } = await service
        .from("provinces")
        .select("id")
        .eq("slug", provinceSlug)
        .maybeSingle();
      if (provinceError) return jsonResponse({ error: provinceError.message }, 500);
      if (!provinceRow?.id) return jsonResponse({ items: [] });
      query = query.eq("province_id", provinceRow.id);
    } else if (province) {
      query = query.ilike("province_name", province);
    }

    const { data, error } = await query;
    if (error) return jsonResponse({ error: error.message }, 500);
    return jsonResponse({ items: data ?? [] });
  } catch (error) {
    return errorResponse(error);
  }
});
