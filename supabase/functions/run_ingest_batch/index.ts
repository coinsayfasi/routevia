import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { buildDistrictContext, ingestDistrict } from "../_shared/ingest.ts";
import { getServiceClient, getUserClient, requireAdminOrWorker } from "../_shared/client.ts";

async function withTimeout<T>(promise: Promise<T>, timeoutMs: number, label: string): Promise<T> {
  return await Promise.race([
    promise,
    new Promise<T>((_, reject) => setTimeout(() => reject(new Error(`${label}_timeout`)), timeoutMs)),
  ]);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const actor = await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as { limit?: number };
    const limit = Math.max(1, Math.min(10, Number(body.limit ?? 5)));

    const userClient = getUserClient(authHeader);
    const service = getServiceClient();

    const claimed = actor.id === "service_role" || actor.id === "worker"
      ? await service.rpc("claim_district_ingest_jobs", { p_limit: limit })
      : await userClient.rpc("claim_district_ingest_jobs", { p_limit: limit });
    if (claimed.error) return jsonResponse({ error: claimed.error.message }, 500);

    const jobs = (claimed.data as Record<string, unknown>[] | null) ?? [];
    const results: Array<Record<string, unknown>> = [];

    for (const job of jobs) {
      const jobId = String(job.id);
      const districtId = String(job.district_id);
      const attempts = Number(job.attempts ?? 0);
      let terminalStatusSet = false;
      let failedReason: string | null = null;

      try {
        console.log(JSON.stringify({ event: "job_start", job_id: jobId, district_id: districtId, attempts }));
        const ctx = await buildDistrictContext(service, districtId);
        if (!ctx) throw new Error("district_not_found");

        const ingested = await withTimeout(
          ingestDistrict(service, ctx),
          120_000,
          "ingest_district",
        );
        const touched =
          Number(ingested.google ?? 0) +
          Number(ingested.osm ?? 0) +
          Number(ingested.curated ?? 0);
        if (touched <= 0) {
          throw new Error("zero_results");
        }
        const { error: doneError } = await service
          .from("district_ingest_jobs")
          .update({
            status: "done",
            last_error: null,
            updated_at: new Date().toISOString(),
          })
          .eq("id", jobId);

        if (doneError) throw doneError;
        terminalStatusSet = true;
        console.log(JSON.stringify({ event: "job_end", job_id: jobId, district_id: districtId, status: "done", touched }));

        results.push({ id: jobId, district_id: districtId, status: "done", ...ingested });
      } catch (error) {
        const nextAttempts = attempts + 1;
        const waitMin = 2 ** Math.min(nextAttempts, 8);
        const jitterMs = Math.floor(Math.random() * 30_000);
        const nextRun = new Date(Date.now() + waitMin * 60 * 1000 + jitterMs).toISOString();
        failedReason = String((error as Error).message).slice(0, 4000);

        await service
          .from("district_ingest_jobs")
          .update({
            status: "failed",
            attempts: nextAttempts,
            next_run_at: nextAttempts > 3
              ? new Date(Date.now() + 3650 * 24 * 60 * 60 * 1000).toISOString()
              : nextRun,
            last_error: failedReason,
            updated_at: new Date().toISOString(),
          })
          .eq("id", jobId);
        terminalStatusSet = true;
        console.log(JSON.stringify({
          event: "job_fail",
          job_id: jobId,
          district_id: districtId,
          reason: failedReason,
          attempts: nextAttempts,
          final_failed: nextAttempts > 3,
        }));

        results.push({ id: jobId, district_id: districtId, status: "failed", error: (error as Error).message });
      } finally {
        if (!terminalStatusSet) {
          const reason = failedReason ?? "job_finally_released";
          await service
            .from("district_ingest_jobs")
            .update({
              status: "failed",
              attempts: attempts + 1,
              last_error: reason,
              next_run_at: new Date(Date.now() + 60_000).toISOString(),
              updated_at: new Date().toISOString(),
            })
            .eq("id", jobId)
            .eq("status", "running");
          console.log(JSON.stringify({
            event: "job_fail",
            job_id: jobId,
            district_id: districtId,
            reason,
            attempts: attempts + 1,
            final_failed: false,
            forced_release: true,
          }));
        }
      }
    }

    return jsonResponse({ ok: true, claimed: jobs.length, results });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
