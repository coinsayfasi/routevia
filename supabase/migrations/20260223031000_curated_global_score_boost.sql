-- One-time curated boost to push premium Top Picks visibility.
update public.places
set score = coalesce(score, 0) + 10,
    updated_at = now()
where source_kind = 'curated'::public.source_kind
  and coalesce(is_published, true) = true;
