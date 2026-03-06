-- Remove invalid media paths and enforce basic path hygiene for future writes.

delete from public.place_media
where storage_path is null
   or btrim(storage_path) = ''
   or position('/' in storage_path) = 0
   or storage_path like '%..%'
   or storage_path like '/%';

alter table public.place_media
  drop constraint if exists place_media_storage_path_format_check;

alter table public.place_media
  add constraint place_media_storage_path_format_check
  check (
    position('/' in storage_path) > 0
    and storage_path not like '%..%'
    and storage_path not like '/%'
  ) not valid;
