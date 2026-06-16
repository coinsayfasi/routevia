-- AI Travel Chat — günlük kullanım takibi
-- Free kullanıcı: günde 3 mesaj
-- Premium kullanıcı: sınırsız

CREATE TABLE IF NOT EXISTS public.ai_chat_logs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  province_slug text NOT NULL DEFAULT '',
  created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ai_chat_logs ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'ai_chat_logs' AND policyname = 'ai_chat_own'
  ) THEN
    CREATE POLICY "ai_chat_own" ON public.ai_chat_logs FOR ALL USING (user_id = auth.uid());
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS ai_chat_logs_user_day_idx
  ON public.ai_chat_logs (user_id, created_at DESC);

-- RPC: kullanıcının bugünkü mesaj sayısını döner
CREATE OR REPLACE FUNCTION public.get_today_ai_chat_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE SECURITY DEFINER
AS $$
  SELECT COUNT(*)::integer
  FROM public.ai_chat_logs
  WHERE user_id = p_user_id
    AND created_at >= date_trunc('day', now() AT TIME ZONE 'UTC');
$$;
