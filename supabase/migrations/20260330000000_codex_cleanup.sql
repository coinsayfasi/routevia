-- Codex artıklarını temizle (idempotent — var olmayanları sessizce atlar)

-- Codex'in eklemiş olabileceği cron job'ları kaldır
SELECT cron.unschedule('scheduled-event-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'scheduled-event-reminders'
);
SELECT cron.unschedule('send-scheduled-event-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'send-scheduled-event-reminders'
);
SELECT cron.unschedule('monthly-event-reminders') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'monthly-event-reminders'
);

-- Codex'in user_event_reminders'a eklemiş olabileceği kolonları kaldır
ALTER TABLE public.user_event_reminders
  DROP COLUMN IF EXISTS remind_at,
  DROP COLUMN IF EXISTS is_enabled,
  DROP COLUMN IF EXISTS reminded_at;
