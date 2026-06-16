-- Add last_digest_at to track when each token last received a weekly digest
alter table public.user_push_tokens
  add column if not exists last_digest_at timestamptz;

-- Index for efficient cron query
create index if not exists user_push_tokens_digest_idx
  on public.user_push_tokens(enabled, last_digest_at nulls first);

-- Schedule weekly digest: every Monday at 09:00 UTC
-- Requires pg_cron extension (enabled in Supabase by default)
select cron.schedule(
  'routevia-weekly-push-digest',         -- job name (idempotent)
  '0 9 * * 1',                            -- every Monday at 09:00 UTC
  $$
  select net.http_post(
    url    := current_setting('app.supabase_url') || '/functions/v1/weekly_push_digest',
    body   := '{}',
    headers := json_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    )
  );
  $$
);
