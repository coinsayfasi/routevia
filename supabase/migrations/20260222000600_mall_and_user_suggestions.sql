begin;

do $$
begin
  if not exists (
    select 1 from pg_enum e
    join pg_type t on t.oid = e.enumtypid
    where t.typname = 'place_category' and e.enumlabel = 'mall'
  ) then
    alter type public.place_category add value 'mall';
  end if;
end $$;

create table if not exists public.place_suggestions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  province_id uuid not null references public.provinces(id) on delete cascade,
  district_id uuid references public.districts(id) on delete set null,
  suggested_name text not null,
  suggested_category public.place_category not null,
  suggested_tags text[] not null default '{}',
  short_note text not null check (char_length(short_note) <= 240),
  lat double precision,
  lng double precision,
  source_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  admin_note text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists place_suggestions_status_idx on public.place_suggestions(status, created_at desc);
create index if not exists place_suggestions_province_idx on public.place_suggestions(province_id);
create index if not exists place_suggestions_user_idx on public.place_suggestions(user_id);

create trigger trg_place_suggestions_updated_at
before update on public.place_suggestions
for each row execute function public.set_updated_at();

alter table public.place_suggestions enable row level security;

create policy "place_suggestions_insert_auth"
on public.place_suggestions
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "place_suggestions_select_own_or_admin"
on public.place_suggestions
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

create policy "place_suggestions_admin_update"
on public.place_suggestions
for update
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

commit;
