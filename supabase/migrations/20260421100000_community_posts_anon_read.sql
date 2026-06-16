-- Allow anon users to read storage objects for approved community posts.
-- This lets guest-mode users see post images without signed URL overhead.

drop policy if exists "Anon read approved community-posts" on storage.objects;
create policy "Anon read approved community-posts"
on storage.objects
for select
to anon
using (
  bucket_id = 'community-posts'
  and exists (
    select 1
    from public.community_posts cp
    where cp.id::text = (storage.foldername(name))[2]
      and cp.status = 'approved'
  )
);

-- community-photos bucket: allow anon read for published images.
drop policy if exists "Anon read community-photos" on storage.objects;
create policy "Anon read community-photos"
on storage.objects
for select
to anon
using (
  bucket_id = 'community-photos'
  and exists (
    select 1
    from public.place_images pi
    where pi.object_path = name
      and pi.is_published = true
      and pi.is_active = true
  )
);

-- Ensure community_posts is readable by anon for the status check above.
grant select (id, status) on public.community_posts to anon;
