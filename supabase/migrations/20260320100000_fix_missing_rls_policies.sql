-- ============================================================
-- Fix missing RLS policies identified in audit (2026-03-20)
-- ============================================================

-- 1. photo_reports — add DELETE policy (users can retract their own reports)
drop policy if exists photo_reports_delete_own on public.photo_reports;
create policy photo_reports_delete_own
  on public.photo_reports
  for delete
  to authenticated
  using (auth.uid() = user_id or public.is_admin(auth.uid()));

-- 2. photo_reports — intentionally no UPDATE policy (audit trail; reports are immutable once submitted)
-- Documented: reports cannot be modified after submission, only deleted or reviewed by admin.

-- 3. place_photos — no UPDATE policy needed for user edits (status is managed by admin/service role only)
-- Users can delete their own photos and re-upload if needed. Deliberate design choice.

-- 4. place_checkins — add DELETE policy (users can remove their own checkins)
drop policy if exists place_checkins_delete_own on public.place_checkins;
create policy place_checkins_delete_own
  on public.place_checkins
  for delete
  to authenticated
  using (auth.uid() = user_id or public.is_admin(auth.uid()));

-- 5. community_posts — strengthen UPDATE policy to explicitly guard status field
-- Users may not change status to 'approved' or 'rejected' directly
drop policy if exists community_posts_update_owner_or_admin on public.community_posts;
create policy community_posts_update_owner_or_admin
  on public.community_posts
  for update
  to authenticated
  using (auth.uid() = user_id or public.is_admin(auth.uid()))
  with check (
    -- Admins can set any status; regular users must not escalate status
    public.is_admin(auth.uid())
    or (
      auth.uid() = user_id
      and status not in ('approved', 'rejected', 'removed')
    )
  );

-- 6. Performance: add missing indexes on reviewed_by foreign keys
create index if not exists community_posts_reviewed_by_idx
  on public.community_posts(reviewed_by, reviewed_at desc)
  where reviewed_by is not null;

create index if not exists community_post_reports_reviewed_by_idx
  on public.community_post_reports(reviewed_by, reviewed_at desc)
  where reviewed_by is not null;

create index if not exists place_story_submissions_reviewed_by_idx
  on public.place_story_submissions(reviewed_by, reviewed_at desc)
  where reviewed_by is not null;
