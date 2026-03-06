import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as {
      limit?: number;
      min_priority?: number;
      max_place_count?: number;
      include_done?: boolean;
    };

    const limit = Math.max(1, Math.min(2000, Number(body.limit ?? 200)));
    const minPriority = Math.max(100, Math.min(10000, Number(body.min_priority ?? 120)));
    const maxPlaceCount = Math.max(0, Math.min(200, Number(body.max_place_count ?? 20)));
    const includeDone = Boolean(body.include_done ?? false);

    const service = getServiceClient();
    const { data, error } = await service.rpc("boost_merkez_ingest_jobs", {
      p_limit: limit,
      p_min_priority: minPriority,
      p_max_place_count: maxPlaceCount,
      p_include_done: includeDone,
    });

    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({
      ok: true,
      result: (data as Record<string, unknown>[] | null)?.[0] ?? {},
      params: { limit, min_priority: minPriority, max_place_count: maxPlaceCount, include_done: includeDone },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
