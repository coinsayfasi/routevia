import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as { action?: "demote" | "unpublish"; limit?: number };
    const action = body.action === "unpublish" ? "unpublish" : "demote";
    const limit = Math.max(1, Math.min(100000, Number(body.limit ?? 5000)));

    const service = getServiceClient();
    const { data, error } = await service.rpc("retro_cleanup_low_quality_food", {
      p_action: action,
      p_limit: limit,
    });

    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({ ok: true, result: (data as Record<string, unknown>[] | null)?.[0] ?? { action, affected: 0 } });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
