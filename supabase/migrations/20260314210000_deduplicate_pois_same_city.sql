-- ============================================================================
-- Deduplication: remove POIs that share the same city, normalised name,
-- and coordinate bucket (~100 m) within the same province/city.
--
-- Dedup key:
--   city (lower-trimmed)
--   + norm_name  (lowercase, non-Turkish-alphanum stripped)
--   + round(lat, 3)   ≈ 111 m bucket
--   + round(lng, 3)   ≈ 86-111 m bucket at Turkey latitudes
--
-- Within each group, KEEP the row that is:
--   1. provenance_verified = true  (prefer verified)
--   2. created_at ASC              (prefer first-ingested / oldest)
--
-- All FK children use ON DELETE CASCADE so a single delete from pois
-- is sufficient.  We still delete child rows explicitly to stay
-- consistent with project conventions and avoid long cascade chains
-- under high-concurrency.
-- ============================================================================

begin;

-- ── 1. Identify duplicate POI ids ────────────────────────────────────────────

create temp table _pois_to_delete on commit drop as
with ranked as (
  select
    id,
    row_number() over (
      partition by
        coalesce(lower(trim(city)), ''),
        lower(regexp_replace(trim(name), '[^a-zA-Z0-9ığüşöçİĞÜŞÖÇ]+', '', 'g')),
        round(lat::numeric, 3),
        round(lng::numeric, 3)
      order by
        provenance_verified desc,   -- keep verified first
        created_at asc              -- then prefer oldest (canonical)
    ) as rn
  from public.pois
)
select id
from ranked
where rn > 1;

-- Safety guard: if somehow everything ended up as duplicate, abort.
do $$
declare
  total_pois  bigint;
  to_delete   bigint;
begin
  select count(*) into total_pois from public.pois;
  select count(*) into to_delete  from _pois_to_delete;
  if to_delete > total_pois * 0.40 then
    raise exception
      'Dedup sanity check failed: would delete % of % pois (>40%%). Aborting.',
      to_delete, total_pois;
  end if;
  raise notice 'Dedup: will delete % duplicate rows out of % total pois.',
    to_delete, total_pois;
end;
$$;

-- ── 2. Delete child rows explicitly (belt-and-suspenders) ────────────────────

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

-- ── 3. Delete the duplicate POIs ─────────────────────────────────────────────

delete from public.pois
where id in (select id from _pois_to_delete);

commit;
