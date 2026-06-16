-- 20260427100000_fix_approve_place_citext_cast.sql
-- Removes the redundant ::citext[] cast that the Supabase linter flags as
-- "type citext[] does not exist". Comparing text[] against a citext column
-- is already case-insensitive in PostgreSQL, so the cast is unnecessary.

create or replace function public.approve_place_submission(
  p_submission_id uuid,
  p_publish_cover boolean default true
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_place_submissions%rowtype;
  v_place_id uuid;
  v_city_name text;
  v_district_name text;
begin
  select *
  into v_submission
  from public.user_place_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'place_submission_not_found';
  end if;

  if v_submission.approved_place_id is not null then
    v_place_id := v_submission.approved_place_id;
  else
    select p.name into v_city_name
    from public.provinces p
    where p.id = v_submission.legacy_province_id;

    select d.name into v_district_name
    from public.districts d
    where d.id = v_submission.legacy_district_id;

    insert into public.pois (
      id,
      name,
      category,
      lat,
      lng,
      city,
      district,
      tags,
      source,
      provenance_verified,
      provenance_checked_at,
      updated_at
    )
    values (
      gen_random_uuid(),
      v_submission.place_name,
      v_submission.category_key,
      v_submission.lat,
      v_submission.lng,
      v_city_name,
      v_district_name,
      to_jsonb(coalesce(v_submission.tag_slugs, '{}'::text[])),
      'user',
      false,
      null,
      now()
    )
    returning id into v_place_id;
  end if;

  perform public.ensure_tag_records(v_submission.tag_slugs);

  insert into public.place_tag_map (place_id, tag_id)
  select
    v_place_id,
    t.id
  from public.tags t
  where t.slug = any (coalesce(v_submission.tag_slugs, '{}'::text[]))
  on conflict do nothing;

  if p_publish_cover is true
     and nullif(trim(coalesce(v_submission.cover_bucket, '')), '') is not null
     and nullif(trim(coalesce(v_submission.cover_object_path, '')), '') is not null then
    insert into public.place_images (
      place_id,
      source_submission_id,
      bucket,
      object_path,
      image_type,
      is_active,
      is_published,
      created_by,
      published_at,
      created_at,
      updated_at
    )
    values (
      v_place_id,
      v_submission.id,
      v_submission.cover_bucket,
      v_submission.cover_object_path,
      'cover',
      true,
      true,
      v_submission.user_id,
      now(),
      v_submission.created_at,
      now()
    )
    on conflict (place_id, bucket, object_path) do nothing;
  end if;

  update public.user_place_submissions
  set
    status = 'approved',
    admin_note = null,
    rejection_reason = null,
    approved_place_id = v_place_id,
    reviewed_at = now(),
    reviewed_by = public.current_admin_actor_id(),
    updated_at = now()
  where id = p_submission_id;

  return v_place_id;
end;
$$;
