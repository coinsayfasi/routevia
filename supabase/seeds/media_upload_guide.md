# Media Upload Guide

Bucket: `public-media`

Path format:
- `public-media/seed/<province_slug>/<place_slug>_1.jpg`

Example:
- `public-media/seed/izmir/ephesus_ancient_city_1.jpg`

Recommended image sizes:
- Thumbnail: 640x360
- Hero: 1280x720

Upload command:
```bash
supabase storage cp ./local/path/image.jpg ss://public-media/seed/izmir/ephesus_ancient_city_1.jpg
```

After upload, set `place_media.storage_path` to the same object path.
