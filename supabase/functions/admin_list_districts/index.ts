import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

type Payload = { province_slug: string };

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as Payload;
    const provinceSlug = String(body.province_slug ?? "").trim();
    if (!provinceSlug) return jsonResponse({ error: "province_slug required" }, 400);

    const service = getServiceClient();
    const province = await service
      .from("provinces")
      .select("id,name,slug")
      .eq("slug", provinceSlug)
      .maybeSingle();

    if (province.error) return jsonResponse({ error: province.error.message }, 500);
    if (!province.data) return jsonResponse({ error: "province_not_found" }, 404);

    const districts = await service
      .from("districts")
      .select("id,name,slug")
      .eq("province_id", province.data.id)
      .order("name", { ascending: true });

    if (districts.error) return jsonResponse({ error: districts.error.message }, 500);

    return jsonResponse({
      province: province.data,
      districts: districts.data ?? [],
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
