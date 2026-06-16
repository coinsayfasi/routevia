-- Fix: grant SELECT/INSERT/UPDATE/DELETE on community_posts and community_post_gallery
-- to authenticated role. Tables had RLS policies but no explicit GRANT, which caused
-- PostgREST to reject queries from the mobile client (same pattern as place_community_state).

grant select, insert, update, delete on public.community_posts to authenticated;
grant select, insert, update, delete on public.community_post_gallery to authenticated;
