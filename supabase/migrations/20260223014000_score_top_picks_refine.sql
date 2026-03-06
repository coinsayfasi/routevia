-- Refine score model and triggers for deterministic fast top-picks support.

create or replace function public.calc_place_score_fields(
  p_google_rating real,
  p_google_review_count int,
  p_popularity_score int,
  p_tags text[],
  p_source_kind public.source_kind,
  p_has_image boolean
)
returns double precision
language sql
immutable
as $$
  select greatest(
    (coalesce(p_google_rating, 0)::double precision * 2.0)
    + (ln(coalesce(p_google_review_count, 0)::double precision + 1.0) * 0.8)
    + (coalesce(p_popularity_score, 0)::double precision * 0.05)
    + (least(coalesce(array_length(p_tags, 1), 0), 8)::double precision * 0.3)
    + (case when p_has_image then 2.0 else 0.0 end)
    + (case when p_source_kind = 'curated' then 1.5 else 0 end),
    0
  );
$$;

create or replace function public.calc_place_score(p_place_id uuid)
returns double precision
language sql
stable
as $$
  select public.calc_place_score_fields(
    p.google_rating,
    p.google_review_count,
    p.popularity_score,
    p.tags,
    p.source_kind,
    exists (select 1 from public.place_media pm where pm.place_id = p.id)
  )
  from public.places p
  where p.id = p_place_id;
$$;

create or replace function public.set_place_score()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_has_image boolean;
begin
  v_has_image := exists (select 1 from public.place_media pm where pm.place_id = new.id);
  new.score := public.calc_place_score_fields(
    new.google_rating,
    new.google_review_count,
    new.popularity_score,
    new.tags,
    new.source_kind,
    v_has_image
  );
  return new;
end;
$$;

drop trigger if exists trg_set_place_score on public.places;
create trigger trg_set_place_score
before insert or update of google_rating, google_review_count, popularity_score, tags, source_kind
on public.places
for each row
execute function public.set_place_score();

create or replace function public.touch_place_score_from_media()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_place_id uuid;
begin
  v_place_id := coalesce(new.place_id, old.place_id);
  if v_place_id is null then
    return coalesce(new, old);
  end if;

  update public.places p
  set score = public.calc_place_score_fields(
    p.google_rating,
    p.google_review_count,
    p.popularity_score,
    p.tags,
    p.source_kind,
    exists (select 1 from public.place_media pm where pm.place_id = p.id)
  )
  where p.id = v_place_id;

  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_place_media_touch_place_score on public.place_media;
create trigger trg_place_media_touch_place_score
after insert or update or delete
on public.place_media
for each row
execute function public.touch_place_score_from_media();

create or replace function public.recompute_place_scores(p_limit int default 2000, p_offset int default 0)
returns table(updated_count int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int := 0;
begin
  with target as (
    select p.id
    from public.places p
    order by p.created_at asc, p.id asc
    limit greatest(1, least(coalesce(p_limit, 2000), 10000))
    offset greatest(0, coalesce(p_offset, 0))
  )
  update public.places p
  set score = public.calc_place_score_fields(
    p.google_rating,
    p.google_review_count,
    p.popularity_score,
    p.tags,
    p.source_kind,
    exists (select 1 from public.place_media pm where pm.place_id = p.id)
  )
  where p.id in (select id from target);

  get diagnostics v_count = row_count;
  return query select v_count;
end;
$$;

grant execute on function public.recompute_place_scores(int, int) to authenticated;

create index if not exists idx_places_district_score on public.places(district_id, score desc);
create index if not exists idx_places_category_score on public.places(category, score desc);
