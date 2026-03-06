drop function if exists public.calc_place_score_fields(
  real,
  int,
  int,
  text[],
  public.source_kind,
  boolean
);

create or replace function public.calc_place_score_fields(
  p_google_rating real,
  p_google_review_count int,
  p_popularity_score int,
  p_tags text[],
  p_source_kind public.source_kind,
  p_has_media boolean
)
returns double precision
language sql
immutable
as $$
  select greatest(
    (coalesce(p_google_rating, 0)::double precision * 2.0)
    + (ln(coalesce(p_google_review_count, 0) + 1) * 0.8)
    + (coalesce(p_popularity_score, 0)::double precision * 0.05)
    + (least(coalesce(array_length(p_tags, 1), 0), 8) * 0.3)
    + (case when p_has_media then 2.0 else 0 end)
    + (case when p_source_kind = 'curated' then 10.0 else 0 end),
    0
  );
$$;

-- Recompute all existing scores after curated bonus update.
-- In some environments publish guards may reject bulk updates; skip hard-fail.
do $$
begin
  perform public.recompute_place_scores(500000, 0);
exception when others then
  raise notice 'recompute_place_scores skipped: %', sqlerrm;
end $$;
