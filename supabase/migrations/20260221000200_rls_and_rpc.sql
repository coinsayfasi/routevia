create or replace function public.is_admin(uid uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = uid and p.role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.provinces enable row level security;
alter table public.districts enable row level security;
alter table public.places enable row level security;
alter table public.place_details enable row level security;
alter table public.place_media enable row level security;
alter table public.trips enable row level security;
alter table public.trip_days enable row level security;
alter table public.trip_stops enable row level security;
alter table public.trip_shares enable row level security;

create policy "public_read_provinces"
on public.provinces
for select
using (true);

create policy "public_read_districts"
on public.districts
for select
using (true);

create policy "public_read_places"
on public.places
for select
using (true);

create policy "public_read_place_details"
on public.place_details
for select
using (true);

create policy "public_read_place_media"
on public.place_media
for select
using (true);

create policy "profiles_select_own_or_admin"
on public.profiles
for select
using (id = auth.uid() or public.is_admin(auth.uid()));

create policy "profiles_update_own"
on public.profiles
for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "profiles_insert_self"
on public.profiles
for insert
with check (id = auth.uid());

create policy "trips_owner_select"
on public.trips
for select
using (user_id = auth.uid());

create policy "trips_owner_insert"
on public.trips
for insert
with check (user_id = auth.uid());

create policy "trips_owner_update"
on public.trips
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "trips_owner_delete"
on public.trips
for delete
using (user_id = auth.uid());

create policy "trip_days_owner_all"
on public.trip_days
for all
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = auth.uid()
  )
);

create policy "trip_stops_owner_all"
on public.trip_stops
for all
using (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = auth.uid()
  )
);

create policy "trip_shares_owner_select"
on public.trip_shares
for select
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

create policy "trip_shares_owner_insert"
on public.trip_shares
for insert
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

create policy "trip_shares_owner_update"
on public.trip_shares
for update
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

create policy "trip_shares_owner_delete"
on public.trip_shares
for delete
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_shares.trip_id
      and t.user_id = auth.uid()
  )
);

create or replace function public.get_shared_trip(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  payload jsonb;
begin
  select jsonb_build_object(
    'trip_id', t.id,
    'days', t.days,
    'transport_mode', t.transport_mode,
    'pace', t.pace,
    'persona_mode', t.persona_mode,
    'preferences', t.preferences,
    'province', jsonb_build_object('id', p.id, 'name', p.name, 'slug', p.slug),
    'days_plan', coalesce(
      (
        select jsonb_agg(day_row order by (day_row->>'day_number')::int)
        from (
          select jsonb_build_object(
            'day_number', td.day_number,
            'stops', coalesce(
              (
                select jsonb_agg(
                  jsonb_build_object(
                    'order_index', ts.order_index,
                    'arrival_time', ts.arrival_time,
                    'duration_min', ts.duration_min,
                    'transport_mode', ts.transport_mode,
                    'place', jsonb_build_object(
                      'id', pl.id,
                      'name', pl.name,
                      'slug', pl.slug,
                      'category', pl.category,
                      'short_summary', pl.short_summary,
                      'best_time', pl.best_time,
                      'duration_min', pl.duration_min,
                      'media', (
                        select coalesce(
                          jsonb_agg(
                            jsonb_build_object(
                              'storage_path', pm.storage_path,
                              'sort_order', pm.sort_order
                            )
                            order by pm.sort_order
                          ),
                          '[]'::jsonb
                        )
                        from public.place_media pm
                        where pm.place_id = pl.id
                      )
                    )
                  )
                  order by ts.order_index
                )
                from public.trip_stops ts
                join public.places pl on pl.id = ts.place_id
                where ts.trip_day_id = td.id
              ),
              '[]'::jsonb
            )
          ) as day_row
          from public.trip_days td
          where td.trip_id = t.id
        ) q
      ),
      '[]'::jsonb
    )
  )
  into payload
  from public.trip_shares s
  join public.trips t on t.id = s.trip_id
  join public.provinces p on p.id = t.province_id
  where s.share_token = p_token and s.is_active = true;

  return payload;
end;
$$;

grant execute on function public.get_shared_trip(text) to anon, authenticated;
