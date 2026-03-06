import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as { max_attempts?: number };
    const maxAttempts = Math.max(1, Math.min(20, Number(body.max_attempts ?? 5)));

    const service = getServiceClient();
    const { data, error } = await service
      .from("district_ingest_jobs")
      .update({
        status: "queued",
        next_run_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("status", "failed")
      .lt("attempts", maxAttempts)
      .select("id");

    if (error) return jsonResponse({ error: error.message }, 500);

    return jsonResponse({ ok: true, requeued: (data ?? []).length, max_attempts: maxAttempts });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
