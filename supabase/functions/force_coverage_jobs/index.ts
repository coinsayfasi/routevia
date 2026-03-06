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
      max_places?: number;
      merkez_only?: boolean;
      preview_limit?: number;
    };

    const limit = Math.max(1, Math.min(2000, Number(body.limit ?? 200)));
    const maxPlaces = Math.max(0, Math.min(200, Number(body.max_places ?? 20)));
    const merkezOnly = body.merkez_only ?? true;
    const previewLimit = Math.max(1, Math.min(50, Number(body.preview_limit ?? 20)));

    const service = getServiceClient();
    const [forced, preview] = await Promise.all([
      service.rpc("force_coverage_queue", {
        p_limit: limit,
        p_max_places: maxPlaces,
        p_merkez_only: merkezOnly,
      }),
      service.rpc("qc_weak_district_ids", {
        p_limit: previewLimit,
        p_max_places: maxPlaces,
        p_merkez_only: merkezOnly,
      }),
    ]);

    if (forced.error) return jsonResponse({ error: forced.error.message }, 500);
    if (preview.error) return jsonResponse({ error: preview.error.message }, 500);

    return jsonResponse({
      ok: true,
      forced: (forced.data as Record<string, unknown>[] | null)?.[0] ?? {},
      preview: (preview.data as Record<string, unknown>[] | null) ?? [],
      params: { limit, max_places: maxPlaces, merkez_only: merkezOnly },
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
