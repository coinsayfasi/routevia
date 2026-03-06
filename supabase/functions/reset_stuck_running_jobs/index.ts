import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as { stale_minutes?: number };
    const staleMinutes = Math.max(1, Math.min(240, Number(body.stale_minutes ?? 10)));
    const cutoff = new Date(Date.now() - staleMinutes * 60 * 1000).toISOString();

    const service = getServiceClient();
    const { data, error } = await service
      .from("district_ingest_jobs")
      .update({
        status: "queued",
        next_run_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        last_error: "stuck_running_requeued",
      })
      .eq("status", "running")
      .lt("updated_at", cutoff)
      .select("id");

    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({ ok: true, requeued: (data ?? []).length, stale_minutes: staleMinutes });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
