-- Private planning details are only read through the owner's trip policies.
-- Public sharing handlers deliberately do not serialize this column.
alter table public.trip_days_clean
  add column if not exists planning_metadata jsonb not null default '{}'::jsonb;
comment on column public.trip_days_clean.planning_metadata is
  'Owner-only planning context, including optional private return point/deadline. Never include in public route snapshots.';
