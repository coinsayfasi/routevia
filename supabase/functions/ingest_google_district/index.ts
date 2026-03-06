import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  return jsonResponse({
    error: "disabled_by_policy",
    message: "Google ingest kalıcı olarak devre dışı. Clean veri için curated/raw->clean akışı kullanın.",
  }, 410);
});
