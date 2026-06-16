-- ============================================================================
-- Production Final Fixes
-- 1. Admin RLS policy for community_posts updates
-- 2. Trigger: sync place_images (approved) → place_community_state.cover_photo
-- 3. Trigger: sync legacy place_photos (approved) → place_community_state.cover_photo
-- 4. Notify user when photo is approved (via notify_user_content_approved)
-- 5. RLS fix: allow admins to update place_community_state
-- ============================================================================

begin;

-- ── 1. Admin can update community_posts (needed for direct-update fallback) ──

drop policy if exists "Admins can update community_posts" on public.community_posts;
create policy "Admins can update community_posts"
  on public.community_posts
  for update
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

-- ── 2. Trigger: place_images approval → cover_photo sync ─────────────────────

create or replace function public.sync_place_images_cover_photo()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_public_url text;
begin
  -- When a place_image is published (new insert or update to is_published=true)
  -- and it's a cover image, update place_community_state.cover_photo
  if new.is_published = true and new.is_active = true and new.deleted_at is null then
    -- Build the public storage URL (project URL is fixed per deployment)
    v_public_url := 'https://xfswonqskciufcnsehfc.supabase.co/storage/v1/object/public/' ||
      new.bucket || '/' || new.object_path;

    -- Upsert place_community_state
    insert into public.place_community_state (place_id, cover_photo, updated_at)
    values (new.place_id, v_public_url, now())
    on conflict (place_id) do update
      set cover_photo = v_public_url,
          updated_at  = now()
    where
      -- Only set as cover if this is a cover image OR the place has no cover yet
      new.image_type = 'cover'
      or public.place_community_state.cover_photo is null
      or public.place_community_state.cover_photo = '';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_sync_place_images_cover_photo on public.place_images;
create trigger trg_sync_place_images_cover_photo
  after insert or update of is_published, is_active, deleted_at
  on public.place_images
  for each row
  execute function public.sync_place_images_cover_photo();

-- ── 3. Trigger: legacy place_photos approval → cover_photo sync ──────────────

create or replace function public.sync_place_photos_cover_photo()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'approved' and (old.status is null or old.status <> 'approved') then
    -- First approved photo for this place → set as cover if none exists
    insert into public.place_community_state (place_id, cover_photo, photo_count, updated_at)
    values (
      new.place_id,
      coalesce(new.image_url, ''),
      1,
      now()
    )
    on conflict (place_id) do update
      set cover_photo  = case
                           when public.place_community_state.cover_photo is null
                             or public.place_community_state.cover_photo = ''
                           then coalesce(new.image_url, '')
                           else public.place_community_state.cover_photo
                         end,
          photo_count  = coalesce(public.place_community_state.photo_count, 0) + 1,
          updated_at   = now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_sync_place_photos_cover_photo on public.place_photos;
create trigger trg_sync_place_photos_cover_photo
  after update of status
  on public.place_photos
  for each row
  execute function public.sync_place_photos_cover_photo();

-- ── 4. Admin RLS: update poi_reviews (needed for review moderation) ───────────

drop policy if exists "Admins can update poi_reviews" on public.poi_reviews;
create policy "Admins can update poi_reviews"
  on public.poi_reviews
  for update
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

-- ── 5. Admin RLS: update place_photos (needed for legacy photo moderation) ────

drop policy if exists "Admins can update place_photos" on public.place_photos;
create policy "Admins can update place_photos"
  on public.place_photos
  for update
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

-- ── 6. Admin RLS: select on user_photo_submissions & user_story_submissions ───

drop policy if exists "Admins can select user_photo_submissions" on public.user_photo_submissions;
create policy "Admins can select user_photo_submissions"
  on public.user_photo_submissions
  for select
  to authenticated
  using (public.is_admin(auth.uid()) or user_id = auth.uid());

drop policy if exists "Admins can update user_photo_submissions" on public.user_photo_submissions;
create policy "Admins can update user_photo_submissions"
  on public.user_photo_submissions
  for update
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

drop policy if exists "Users can insert user_photo_submissions" on public.user_photo_submissions;
create policy "Users can insert user_photo_submissions"
  on public.user_photo_submissions
  for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "Admins can select user_story_submissions" on public.user_story_submissions;
create policy "Admins can select user_story_submissions"
  on public.user_story_submissions
  for select
  to authenticated
  using (public.is_admin(auth.uid()) or user_id = auth.uid());

drop policy if exists "Admins can update user_story_submissions" on public.user_story_submissions;
create policy "Admins can update user_story_submissions"
  on public.user_story_submissions
  for update
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

-- ── 7. Ensure RLS is enabled on new tables ────────────────────────────────────

alter table if exists public.user_photo_submissions enable row level security;
alter table if exists public.user_story_submissions enable row level security;
alter table if exists public.user_place_submissions  enable row level security;
alter table if exists public.place_images            enable row level security;
alter table if exists public.place_stories           enable row level security;
alter table if exists public.admin_audit_logs        enable row level security;
alter table if exists public.moderation_queue        enable row level security;

-- ── 8. Public can read approved/published content only ────────────────────────

drop policy if exists "Public reads published place_stories" on public.place_stories;
create policy "Public reads published place_stories"
  on public.place_stories
  for select
  using (is_published = true and deleted_at is null);

drop policy if exists "Public reads published place_images" on public.place_images;
create policy "Public reads published place_images"
  on public.place_images
  for select
  using (is_published = true and is_active = true and deleted_at is null);

-- Admins can read everything
drop policy if exists "Admins can read all place_stories" on public.place_stories;
create policy "Admins can read all place_stories"
  on public.place_stories
  for select
  to authenticated
  using (public.is_admin(auth.uid()));

drop policy if exists "Admins can read all place_images" on public.place_images;
create policy "Admins can read all place_images"
  on public.place_images
  for select
  to authenticated
  using (public.is_admin(auth.uid()));

-- Admins can do everything on moderation tables
drop policy if exists "Admins can manage moderation_queue" on public.moderation_queue;
create policy "Admins can manage moderation_queue"
  on public.moderation_queue
  for all
  to authenticated
  using (public.is_admin(auth.uid()))
  with check (public.is_admin(auth.uid()));

drop policy if exists "Admins can read admin_audit_logs" on public.admin_audit_logs;
create policy "Admins can read admin_audit_logs"
  on public.admin_audit_logs
  for select
  to authenticated
  using (public.is_admin(auth.uid()));

commit;
