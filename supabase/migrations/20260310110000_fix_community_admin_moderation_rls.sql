alter table public.place_reviews enable row level security;
alter table public.place_photos enable row level security;
alter table public.place_community_state enable row level security;

drop policy if exists place_reviews_update_own on public.place_reviews;
create policy place_reviews_update_own
on public.place_reviews
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_photos_update_own on public.place_photos;
create policy place_photos_update_own
on public.place_photos
for update
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()))
with check (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists place_community_state_admin_write on public.place_community_state;
create policy place_community_state_admin_write
on public.place_community_state
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));
