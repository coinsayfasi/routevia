-- Schedule monthly event reminder push: 1st of each month at 09:00 UTC
-- Calls send_event_reminders edge function for all bookmarked festivals
select cron.schedule(
  'routevia-monthly-event-reminders',       -- job name (idempotent)
  '0 9 1 * *',                              -- 1st of every month at 09:00 UTC
  $$
  select net.http_post(
    url    := current_setting('app.supabase_url') || '/functions/v1/send_event_reminders',
    body   := '{}',
    headers := json_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    )
  );
  $$
);
