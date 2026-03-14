-- ─────────────────────────────────────────────────────────────────────
-- Weather cache table
-- TTL-based shared cache keyed by city_slug (or city_slug:district_slug)
-- Prevents repeated Open-Meteo calls for the same location
-- ─────────────────────────────────────────────────────────────────────

create table if not exists public.weather_cache (
  id                      uuid          primary key default gen_random_uuid(),
  cache_key               text          unique not null,   -- e.g. "antalya" or "antalya:konyaalti"
  city_slug               text          not null,
  city_name               text          not null,
  district_slug           text,
  district_name           text,
  lat                     numeric(9, 6) not null,
  lng                     numeric(9, 6) not null,
  temperature             numeric(4, 1),
  apparent_temperature    numeric(4, 1),
  weather_code            int,
  condition_text          text,
  condition_emoji         text,
  is_day                  boolean,
  precipitation_probability int,
  wind_speed              numeric(5, 1),
  humidity                int,
  sunrise                 text,
  sunset                  text,
  suggestion_mode         text,          -- outdoor | indoor | sunset | mixed
  provider                text          not null default 'open-meteo',
  payload                 jsonb         not null default '{}'::jsonb,
  fetched_at              timestamptz   not null default now(),
  expires_at              timestamptz   not null,
  created_at              timestamptz   not null default now()
);

-- Fast lookup by cache key (primary access pattern)
create index if not exists weather_cache_key_idx
  on public.weather_cache (cache_key);

-- Index for cleanup of expired rows
create index if not exists weather_cache_expires_idx
  on public.weather_cache (expires_at);

-- RLS: public read (weather is not user-specific), service writes only
alter table public.weather_cache enable row level security;

drop policy if exists "weather_cache_public_read" on public.weather_cache;
create policy "weather_cache_public_read"
  on public.weather_cache for select using (true);

-- Clean up rows expired more than 24h ago (run periodically or on next write)
-- No scheduled job needed; the edge function uses expires_at to detect staleness.
-- Optionally: DELETE FROM weather_cache WHERE expires_at < now() - interval '24 hours'
