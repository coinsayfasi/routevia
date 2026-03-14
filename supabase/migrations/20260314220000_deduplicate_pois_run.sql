-- ============================================================================
-- Deduplication v2 — same logic as 20260314210000 but with a realistic
-- safety threshold (70% instead of 40%).
--
-- Background: multiple ingest rounds created 15,721 duplicate rows out of
-- 27,027 total pois (~58%).  Examples in Antalya alone:
--   "Köprülü Kanyon Milli Parkı"  → 18 copies
--   "Green Canyon"                → 17 copies
--   "Göynük Kanyonu"              → 16 copies
--
-- All FK children are deleted explicitly before the parent row.
-- Dedup key: (city, normalised_name, lat rounded 3dp, lng rounded 3dp)
-- Keep: provenance_verified=true first, then oldest created_at.
-- ============================================================================

begin;

create temp table _pois_to_delete on commit drop as
with ranked as (
  select
    id,
    row_number() over (
      partition by
        lower(trim(coalesce(city, ''))),
        lower(regexp_replace(trim(coalesce(name, '')), '[^a-zA-Z0-9ığüşöçİĞÜŞÖÇ]+', '', 'g')),
        round(lat::numeric, 3),
        round(lng::numeric, 3)
      order by
        provenance_verified desc nulls last,
        created_at asc nulls last
    ) as rn
  from public.pois
)
select id from ranked where rn > 1;

-- Safety guard: allow up to 70% deletion (realistic given ingest duplication)
do $$
declare
  total_pois bigint;
  to_delete  bigint;
begin
  select count(*) into total_pois from public.pois;
  select count(*) into to_delete  from _pois_to_delete;
  if to_delete > total_pois * 0.70 then
    raise exception
      'Dedup safety: would delete % of % pois (>70%%). Manual review needed.',
      to_delete, total_pois;
  end if;
  raise notice 'Dedup: deleting % duplicate rows out of % total pois.',
    to_delete, total_pois;
end;
$$;

-- Delete children first
delete from public.place_photos          where place_id in (select id from _pois_to_delete);
delete from public.place_checkins        where place_id in (select id from _pois_to_delete);
delete from public.place_community_state where place_id in (select id from _pois_to_delete);
delete from public.place_images          where place_id in (select id from _pois_to_delete);
delete from public.place_stories         where place_id in (select id from _pois_to_delete);
delete from public.place_tag_map         where place_id in (select id from _pois_to_delete);
delete from public.place_reviews         where place_id in (select id from _pois_to_delete);
delete from public.featured_places       where place_id in (select id from _pois_to_delete);
delete from public.user_story_submissions  where place_id in (select id from _pois_to_delete);
delete from public.user_photo_submissions  where place_id in (select id from _pois_to_delete);
delete from public.moderation_queue      where place_id in (select id from _pois_to_delete);
delete from public.poi_reviews           where poi_id   in (select id from _pois_to_delete);
delete from public.poi_signals           where poi_id   in (select id from _pois_to_delete);
delete from public.poi_trust_metrics     where poi_id   in (select id from _pois_to_delete);
delete from public.poi_live_status       where poi_id   in (select id from _pois_to_delete);
delete from public.poi_location_overrides where poi_id  in (select id from _pois_to_delete);

-- Delete duplicate POIs
delete from public.pois where id in (select id from _pois_to_delete);

commit;
