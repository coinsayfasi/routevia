-- DB trigger: notify admins via push when a community post moves to 'pending'.
-- Uses pg_net to call admin_send_push edge function (service-role key).

create or replace function public.notify_admin_new_pending_post()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Only fire when status transitions to 'pending'
  if (TG_OP = 'UPDATE' and old.status = new.status) then
    return new;
  end if;
  if new.status <> 'pending' then
    return new;
  end if;

  -- Send push notification to all admins (userId = null → broadcast to admin tokens)
  perform net.http_post(
    url     := current_setting('app.supabase_url') || '/functions/v1/admin_send_push',
    body    := json_build_object(
      'title', 'Yeni İnceleme Bekliyor',
      'body',  coalesce(nullif(trim(new.title), ''), 'Başlıksız yazı') || ' — moderasyon kuyruğu',
      'data',  json_build_object('type', 'admin_pending_post', 'post_id', new.id)
    )::text::jsonb,
    headers := json_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    )
  );

  return new;
end;
$$;

drop trigger if exists trg_notify_admin_pending_post on public.community_posts;
create trigger trg_notify_admin_pending_post
  after insert or update of status
  on public.community_posts
  for each row
  execute function public.notify_admin_new_pending_post();
