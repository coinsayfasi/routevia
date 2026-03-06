alter table if exists public.places
  add column if not exists score double precision not null default 0;

create or replace function public.compute_place_score(
  p_google_rating real,
  p_google_review_count int,
  p_popularity int,
  p_tags text[],
  p_has_image boolean
)
returns double precision
language sql
immutable
as $$
  select
    (coalesce(p_google_rating, 0)::double precision * 2.0)
    + ln(coalesce(p_google_review_count, 0)::double precision + 1.0)
    + coalesce(p_popularity, 0)::double precision
    + (coalesce(array_length(p_tags, 1), 0)::double precision * 0.5)
    + (case when p_has_image then 2.0 else 0.0 end);
$$;

create or replace function public.refresh_place_score(p_place_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_has_image boolean;
begin
  select exists(
    select 1 from public.place_media m where m.place_id = p_place_id
  ) into v_has_image;

  update public.places p
  set score = public.compute_place_score(
    p.google_rating,
    p.google_review_count,
    p.popularity_score,
    p.tags,
    v_has_image
  )
  where p.id = p_place_id;
end;
$$;

create or replace function public.trg_places_refresh_score()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.refresh_place_score(coalesce(new.id, old.id));
  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_places_refresh_score on public.places;
create trigger trg_places_refresh_score
after insert or update of google_rating, google_review_count, popularity_score, tags
on public.places
for each row
execute function public.trg_places_refresh_score();

drop trigger if exists trg_place_media_refresh_score_iud on public.place_media;
create trigger trg_place_media_refresh_score_iud
after insert or update or delete
on public.place_media
for each row
execute function public.trg_places_refresh_score();

-- Backfill intentionally skipped to avoid side effects on existing publish validation triggers.
-- Scores are refreshed automatically for new/updated rows and media changes.

create index if not exists places_score_idx on public.places(score desc);
