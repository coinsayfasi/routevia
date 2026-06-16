do $$
declare
  v_place_id uuid;
  v_user_id uuid;
begin
  for v_place_id in
    select distinct place_id from public.place_photos
    union
    select distinct place_id from public.place_reviews
    union
    select distinct place_id from public.place_checkins
  loop
    perform public.recalc_place_community_state(v_place_id);
  end loop;

  for v_user_id in
    select distinct user_id from public.place_photos
    union
    select distinct user_id from public.place_reviews
  loop
    perform public.recalc_user_trust(v_user_id);
  end loop;
end $$;
