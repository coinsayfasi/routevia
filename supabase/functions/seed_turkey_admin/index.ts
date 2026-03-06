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
    const [provinceRes, districtRes] = await Promise.all([
      service.from("provinces").select("id", { count: "exact", head: true }),
      service.from("districts").select("id", { count: "exact", head: true }),
    ]);

    const provinceCount = provinceRes.count ?? 0;
    const districtCount = districtRes.count ?? 0;

    return jsonResponse({
      ok: provinceCount === 81 && districtCount >= 900,
      provinces: provinceCount,
      districts: districtCount,
      note: "Boundaries are loaded from SQL migration data/seed/turkey_admin_seed.sql",
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
