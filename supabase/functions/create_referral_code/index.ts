import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const service = getServiceClient();

    const rpc = await service.rpc("generate_referral_code", { p_user_id: user.id });
    if (rpc.error) return jsonResponse({ error: rpc.error.message }, 500);

    return jsonResponse({ code: String(rpc.data ?? "") });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
