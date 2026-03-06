import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const service = getServiceClient();
    const { data: districts, error } = await service
      .from("districts")
      .select("id,province_id");

    if (error) return jsonResponse({ error: error.message }, 500);

    const { data: existingJobs, error: existingError } = await service
      .from("district_ingest_jobs")
      .select("district_id");
    if (existingError) return jsonResponse({ error: existingError.message }, 500);

    const existingDistricts = new Set(
      ((existingJobs as Record<string, unknown>[] | null) ?? []).map((j) => String(j.district_id)),
    );

    const jobs = ((districts as Record<string, unknown>[] | null) ?? [])
      .filter((d) => !existingDistricts.has(String(d.id)))
      .map((d) => ({
        district_id: String(d.id),
        province_id: String(d.province_id),
        status: "queued",
        next_run_at: new Date().toISOString(),
      }));

    if (jobs.length > 0) {
      const { error: upsertErr } = await service
        .from("district_ingest_jobs")
        .upsert(jobs, { onConflict: "district_id" });
      if (upsertErr) return jsonResponse({ error: upsertErr.message }, 500);
    }

    return jsonResponse({ ok: true, inserted: jobs.length, skipped_existing: existingDistricts.size });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
