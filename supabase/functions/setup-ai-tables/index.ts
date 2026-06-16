import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";
import { corsHeaders, jsonResponse, errorResponse } from "../_shared/http.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrService(authHeader);

    const service = getServiceClient();

    // Use postgres directly via DB URL
    const dbUrl = Deno.env.get("SUPABASE_DB_URL");
    if (!dbUrl) return jsonResponse({ error: "no db url" }, 500);

    const { Pool } = await import("https://deno.land/x/postgres@v0.17.0/mod.ts");
    const pool = new Pool(dbUrl, 1, true);
    const conn = await pool.connect();
    try {
      await conn.queryObject(`
        CREATE TABLE IF NOT EXISTS public.ai_chat_logs (
          id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
          province_slug text NOT NULL DEFAULT '',
          created_at timestamptz NOT NULL DEFAULT now()
        );
        ALTER TABLE public.ai_chat_logs ENABLE ROW LEVEL SECURITY;
        DO $$ BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_policies WHERE tablename='ai_chat_logs' AND policyname='ai_chat_own'
          ) THEN
            CREATE POLICY "ai_chat_own" ON public.ai_chat_logs FOR ALL USING (user_id = auth.uid());
          END IF;
        END $$;
        CREATE INDEX IF NOT EXISTS ai_chat_logs_user_day_idx
          ON public.ai_chat_logs (user_id, created_at DESC);
      `);
      return jsonResponse({ ok: true, message: "ai_chat_logs table ready" });
    } finally {
      conn.release();
      await pool.end();
    }
  } catch (err) {
    return errorResponse(err);
  }
});
