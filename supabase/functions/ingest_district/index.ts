import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { buildDistrictContext, ingestDistrict } from "../_shared/ingest.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const { district_id } = (await req.json()) as { district_id?: string };
    if (!district_id) return jsonResponse({ error: "district_id required" }, 400);

    const service = getServiceClient();
    const ctx = await buildDistrictContext(service, district_id);
    if (!ctx) return jsonResponse({ error: "district not found" }, 404);

    const result = await ingestDistrict(service, ctx);

    return jsonResponse({ ok: true, district_id, result });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
