begin;

create or replace function public.current_admin_actor_id()
returns uuid
language plpgsql
stable
set search_path = public
as $$
declare
  v_actor_setting text;
begin
  v_actor_setting := nullif(current_setting('routevia.admin_actor_id', true), '');

  if v_actor_setting is not null then
    return v_actor_setting::uuid;
  end if;

  return auth.uid();
end;
$$;

create or replace function public.resolve_admin_actor_id(p_actor_user_id uuid default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_auth_uid uuid := auth.uid();
  v_auth_role text := auth.role();
begin
  if v_auth_uid is not null and public.is_admin(v_auth_uid) then
    return v_auth_uid;
  end if;

  if v_auth_role = 'service_role' then
    if p_actor_user_id is null then
      return null;
    end if;

    if public.is_admin(p_actor_user_id) then
      return p_actor_user_id;
    end if;

    raise exception 'admin_actor_invalid';
  end if;

  if current_user = 'postgres' then
    return p_actor_user_id;
  end if;

  raise exception 'admin_required';
end;
$$;

create or replace function public.write_admin_audit_log(
  p_action text,
  p_target_table text,
  p_target_id uuid,
  p_queue_id uuid default null,
  p_old_data jsonb default null,
  p_new_data jsonb default null,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.admin_audit_logs (
    admin_user_id,
    action,
    target_table,
    target_id,
    moderation_queue_id,
    old_data,
    new_data,
    metadata
  )
  values (
    public.current_admin_actor_id(),
    p_action,
    p_target_table,
    p_target_id,
    p_queue_id,
    p_old_data,
    p_new_data,
    coalesce(p_metadata, '{}'::jsonb)
  );
end;
$$;

create or replace function public.publish_story_submission(
  p_submission_id uuid,
  p_admin_note text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_story_submissions%rowtype;
  v_story_id uuid;
begin
  select *
  into v_submission
  from public.user_story_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'story_submission_not_found';
  end if;

  insert into public.place_stories (
    place_id,
    source_submission_id,
    author_user_id,
    title,
    story_kind,
    story_text,
    admin_note,
    is_published,
    published_at,
    created_at,
    updated_at
  )
  values (
    v_submission.place_id,
    v_submission.id,
    v_submission.user_id,
    v_submission.title,
    v_submission.story_kind,
    v_submission.story_text,
    coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), v_submission.admin_note),
    true,
    now(),
    v_submission.created_at,
    now()
  )
  on conflict (source_submission_id) do update
  set
    title = excluded.title,
    story_kind = excluded.story_kind,
    story_text = excluded.story_text,
    admin_note = excluded.admin_note,
    is_published = true,
    unpublished_at = null,
    published_at = coalesce(public.place_stories.published_at, now()),
    updated_at = now()
  returning id into v_story_id;

  update public.user_story_submissions
  set
    status = 'approved',
    admin_note = coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), admin_note),
    rejection_reason = null,
    approved_story_id = v_story_id,
    reviewed_at = now(),
    reviewed_by = public.current_admin_actor_id(),
    updated_at = now()
  where id = p_submission_id;

  return v_story_id;
end;
$$;

create or replace function public.publish_photo_submission(
  p_submission_id uuid,
  p_admin_note text default null,
  p_set_cover boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_submission public.user_photo_submissions%rowtype;
  v_image_id uuid;
  v_image_type public.place_image_kind := case when p_set_cover then 'cover'::public.place_image_kind else 'community'::public.place_image_kind end;
begin
  select *
  into v_submission
  from public.user_photo_submissions
  where id = p_submission_id
  for update;

  if not found then
    raise exception 'photo_submission_not_found';
  end if;

  insert into public.place_images (
    place_id,
    source_submission_id,
    bucket,
    object_path,
    image_type,
    mime_type,
    width,
    height,
    file_size_bytes,
    alt_text,
    is_active,
    is_published,
    created_by,
    published_at,
    created_at,
    updated_at
  )
  values (
    v_submission.place_id,
    v_submission.id,
    v_submission.bucket,
    v_submission.object_path,
    v_image_type,
    v_submission.mime_type,
    v_submission.width,
    v_submission.height,
    v_submission.file_size_bytes,
    v_submission.caption,
    true,
    true,
    v_submission.user_id,
    now(),
    v_submission.created_at,
    now()
  )
  on conflict (place_id, bucket, object_path) do update
  set
    image_type = excluded.image_type,
    mime_type = excluded.mime_type,
    width = excluded.width,
    height = excluded.height,
    file_size_bytes = excluded.file_size_bytes,
    alt_text = excluded.alt_text,
    is_active = true,
    is_published = true,
    deleted_at = null,
    updated_at = now()
  returning id into v_image_id;

  update public.user_photo_submissions
  set
    status = 'approved',
    admin_note = coalesce(nullif(trim(coalesce(p_admin_note, '')), ''), admin_note),
    rejection_reason = null,
    approved_place_image_id = v_image_id,
    reviewed_at = now(),
    reviewed_by = public.current_admin_actor_id(),
    updated_at = now()
  where id = p_submission_id;

  return v_image_id;
end;
$$;

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
  where t.slug = any (coalesce(v_submission.tag_slugs, '{}'::text[])::citext[])
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

create or replace function public.admin_moderate_submission(
  p_submission_type public.moderation_submission_type,
  p_submission_id uuid,
  p_decision public.moderation_status,
  p_admin_note text default null,
  p_rejection_reason text default null,
  p_publish boolean default true,
  p_set_cover boolean default false,
  p_actor_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_queue_before public.moderation_queue%rowtype;
  v_result_id uuid;
  v_actor_user_id uuid;
begin
  v_actor_user_id := public.resolve_admin_actor_id(p_actor_user_id);
  perform set_config('routevia.admin_actor_id', coalesce(v_actor_user_id::text, ''), true);

  select *
  into v_queue_before
  from public.moderation_queue
  where submission_type = p_submission_type
    and submission_id = p_submission_id
  for update;

  if not found then
    raise exception 'moderation_queue_row_not_found';
  end if;

  if p_submission_type = 'story_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.publish_story_submission(p_submission_id, p_admin_note);
    else
      update public.user_story_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = public.current_admin_actor_id(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  elsif p_submission_type = 'photo_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.publish_photo_submission(p_submission_id, p_admin_note, p_set_cover);
    else
      update public.user_photo_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = public.current_admin_actor_id(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  elsif p_submission_type = 'place_submission' then
    if p_decision = 'approved' and p_publish then
      v_result_id := public.approve_place_submission(p_submission_id);
    else
      update public.user_place_submissions
      set
        status = p_decision,
        admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
        rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
        reviewed_at = now(),
        reviewed_by = public.current_admin_actor_id(),
        updated_at = now()
      where id = p_submission_id;
    end if;
  else
    raise exception 'unsupported_submission_type';
  end if;

  update public.moderation_queue
  set
    status = p_decision,
    admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
    rejection_reason = nullif(trim(coalesce(p_rejection_reason, '')), ''),
    reviewed_at = now(),
    reviewed_by = public.current_admin_actor_id(),
    updated_at = now()
  where submission_type = p_submission_type
    and submission_id = p_submission_id;

  perform public.write_admin_audit_log(
    'moderate_submission',
    p_submission_type::text,
    p_submission_id,
    v_queue_before.id,
    to_jsonb(v_queue_before),
    (
      select to_jsonb(mq)
      from public.moderation_queue mq
      where mq.id = v_queue_before.id
    ),
    jsonb_build_object(
      'decision', p_decision,
      'publish', p_publish,
      'set_cover', p_set_cover,
      'result_id', v_result_id,
      'actor_user_id', public.current_admin_actor_id()
    )
  );

  return jsonb_build_object(
    'submission_type', p_submission_type,
    'submission_id', p_submission_id,
    'decision', p_decision,
    'result_id', v_result_id
  );
end;
$$;

create or replace function public.admin_unpublish_story(
  p_story_id uuid,
  p_admin_note text default null,
  p_actor_user_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_user_id uuid;
begin
  v_actor_user_id := public.resolve_admin_actor_id(p_actor_user_id);
  perform set_config('routevia.admin_actor_id', coalesce(v_actor_user_id::text, ''), true);

  update public.place_stories
  set
    is_published = false,
    unpublished_at = now(),
    admin_note = nullif(trim(coalesce(p_admin_note, '')), ''),
    updated_at = now()
  where id = p_story_id;

  perform public.write_admin_audit_log(
    'unpublish_story',
    'place_stories',
    p_story_id,
    null,
    null,
    (
      select to_jsonb(ps)
      from public.place_stories ps
      where ps.id = p_story_id
    ),
    jsonb_build_object(
      'admin_note', p_admin_note,
      'actor_user_id', public.current_admin_actor_id()
    )
  );
end;
$$;

commit;
