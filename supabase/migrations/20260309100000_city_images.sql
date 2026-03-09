-- city_images: Pexels destination cover image cache (Privacy-Safe Proxy Pattern)
-- Edge Function holds the API key; client never touches Pexels directly.

create table if not exists public.city_images (
  id           uuid        primary key default gen_random_uuid(),
  city_name    text        not null,
  city_slug    text        not null unique,
  image_url    text        not null,
  photographer text,
  source       text        not null default 'pexels',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists city_images_city_slug_idx on public.city_images (city_slug);

alter table public.city_images enable row level security;

-- Anyone (including anon users browsing without login) can read cached images
create policy "Public can read city images"
  on public.city_images for select
  using (true);

-- Only service_role (Edge Function) can write
-- No INSERT/UPDATE/DELETE policy for authenticated — writes only via service_role key
