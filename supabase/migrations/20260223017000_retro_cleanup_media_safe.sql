create or replace function public.retro_cleanup_low_quality_food(
  p_action text default 'demote',
  p_limit int default 5000
)
returns table (
  action text,
  affected int
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_action text := lower(coalesce(p_action, 'demote'));
  v_limit int := greatest(1, least(100000, coalesce(p_limit, 5000)));
begin
  if v_action not in ('demote', 'unpublish') then
    raise exception 'invalid_action';
  end if;

  if v_action = 'demote' then
    return query
    with target as (
      select p.id
      from public.places p
      left join public.community_place_stats cps on cps.place_id = p.id
      where p.category in ('food', 'cafe', 'lodging')
        and p.source_kind <> 'curated'
        and exists (select 1 from public.place_media pm where pm.place_id = p.id)
        and (
          (
            coalesce(p.google_rating, 0) > 0
            and not (
              (p.google_rating >= 4.3 and coalesce(p.google_review_count, 0) >= 150)
              or (p.google_rating >= 4.5 and coalesce(p.google_review_count, 0) >= 80)
            )
            and not (coalesce(cps.avg_rating, 0) >= 4.4 and coalesce(cps.review_count, 0) >= 20)
          )
          or (
            coalesce(p.google_rating, 0) = 0
            and coalesce(cps.review_count, 0) < 20
          )
        )
      order by p.updated_at asc, p.id asc
      limit v_limit
    ), upd as (
      update public.places p
      set
        score = greatest(0, coalesce(p.score, 0) - 8),
        popularity_score = greatest(0, coalesce(p.popularity_score, 0) - 15),
        updated_at = now()
      where p.id in (select id from target)
      returning p.id
    )
    select 'demote'::text as action, count(*)::int as affected
    from upd;
  else
    return query
    with target as (
      select p.id
      from public.places p
      left join public.community_place_stats cps on cps.place_id = p.id
      where p.category in ('food', 'cafe', 'lodging')
        and p.source_kind <> 'curated'
        and exists (select 1 from public.place_media pm where pm.place_id = p.id)
        and (
          (
            coalesce(p.google_rating, 0) > 0
            and not (
              (p.google_rating >= 4.3 and coalesce(p.google_review_count, 0) >= 150)
              or (p.google_rating >= 4.5 and coalesce(p.google_review_count, 0) >= 80)
            )
            and not (coalesce(cps.avg_rating, 0) >= 4.4 and coalesce(cps.review_count, 0) >= 20)
          )
          or (
            coalesce(p.google_rating, 0) = 0
            and coalesce(cps.review_count, 0) < 20
          )
        )
      order by p.updated_at asc, p.id asc
      limit v_limit
    ), upd as (
      update public.places p
      set
        is_published = false,
        updated_at = now()
      where p.id in (select id from target)
      returning p.id
    )
    select 'unpublish'::text as action, count(*)::int as affected
    from upd;
  end if;
end;
$$;
