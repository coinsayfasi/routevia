#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const args = {
    dir: '',
    province: '',
    district: '',
    dryRun: false,
    bucket: 'public-media',
    prefix: 'curated',
  };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a.startsWith('--dir=')) args.dir = a.slice(6);
    else if (a === '--dir') args.dir = argv[++i] ?? '';
    else if (a.startsWith('--province=')) args.province = a.slice(11);
    else if (a.startsWith('--district=')) args.district = a.slice(11);
    else if (a.startsWith('--bucket=')) args.bucket = a.slice(9);
    else if (a.startsWith('--prefix=')) args.prefix = a.slice(9);
  }
  return args;
}

function loadEnv(envPath) {
  const out = {};
  if (!fs.existsSync(envPath)) return out;
  for (const line of fs.readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i <= 0) continue;
    out[t.slice(0, i).trim()] = t.slice(i + 1).trim().replace(/^"|"$/g, '');
  }
  return out;
}

function slugify(value) {
  return String(value ?? '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ş', 's')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function mimeFromFile(fileName) {
  const e = path.extname(fileName).toLowerCase();
  if (e === '.png') return 'image/png';
  if (e === '.webp') return 'image/webp';
  return 'image/jpeg';
}

function parseFileName(baseName) {
  // accepted:
  //   place-slug.jpg
  //   place-slug__2.jpg
  const m = baseName.match(/^(.*?)(?:__(\d+))?$/);
  if (!m) return { slug: baseName, sortOrder: 0 };
  return {
    slug: slugify(m[1] || baseName),
    sortOrder: Math.max(0, Number(m[2] ?? 0) || 0),
  };
}

async function fetchJson(url, init) {
  const res = await fetch(url, { ...init, signal: AbortSignal.timeout(25000) });
  const text = await res.text();
  const json = text ? JSON.parse(text) : {};
  if (!res.ok) throw new Error(`HTTP ${res.status} ${url}: ${JSON.stringify(json)}`);
  return json;
}

async function main() {
  const args = parseArgs(process.argv);
  const repoRoot = path.resolve(process.cwd(), '..', '..');
  const env = { ...process.env, ...loadEnv(path.join(repoRoot, '.env')) };
  const supabaseUrl = env.SUPABASE_URL;
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY eksik');
  if (!args.dir) throw new Error('--dir gerekli (gorsel klasoru)');
  const dir = path.resolve(process.cwd(), args.dir);
  if (!fs.existsSync(dir)) throw new Error(`Klasor bulunamadi: ${dir}`);

  const files = fs.readdirSync(dir)
    .filter((f) => /\.(jpg|jpeg|png|webp)$/i.test(f))
    .sort();
  if (files.length === 0) {
    console.log('Yuklenecek gorsel yok.');
    return;
  }

  const filters = [];
  if (args.province) filters.push(`province_slug=eq.${slugify(args.province)}`);
  if (args.district) filters.push(`district_slug=eq.${slugify(args.district)}`);
  const q = filters.length ? `&${filters.join('&')}` : '';

  const places = await fetchJson(
    `${supabaseUrl}/rest/v1/places_with_coords?select=id,slug,province_slug,district_slug${q}&limit=100000`,
    { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
  );
  const placeBySlug = new Map(places.map((p) => [String(p.slug), p]));

  let uploaded = 0;
  let linked = 0;
  let skipped = 0;
  for (const file of files) {
    const full = path.join(dir, file);
    const ext = path.extname(file).toLowerCase();
    const base = path.basename(file, ext);
    const { slug, sortOrder } = parseFileName(base);
    const place = placeBySlug.get(slug);
    if (!place) {
      skipped += 1;
      console.log(`skip(no_place): ${file}`);
      continue;
    }

    const storagePath = `${args.prefix}/${place.province_slug}/${place.district_slug}/${slug}${sortOrder > 0 ? `__${sortOrder}` : ''}${ext}`;
    if (!args.dryRun) {
      const bin = fs.readFileSync(full);
      const upRes = await fetch(
        `${supabaseUrl}/storage/v1/object/${args.bucket}/${storagePath}`,
        {
          method: 'POST',
          headers: {
            apikey: serviceKey,
            Authorization: `Bearer ${serviceKey}`,
            'Content-Type': mimeFromFile(file),
            'x-upsert': 'true',
          },
          body: bin,
        },
      );
      if (!upRes.ok && upRes.status !== 409) {
        const t = await upRes.text();
        throw new Error(`upload_failed ${file}: ${upRes.status} ${t}`);
      }

      await fetchJson(
        `${supabaseUrl}/rest/v1/place_media?on_conflict=place_id,storage_path`,
        {
          method: 'POST',
          headers: {
            apikey: serviceKey,
            Authorization: `Bearer ${serviceKey}`,
            'Content-Type': 'application/json',
            Prefer: 'resolution=merge-duplicates,return=minimal',
          },
          body: JSON.stringify({
            place_id: place.id,
            storage_path: `${args.bucket}/${storagePath}`,
            source_kind: 'curated',
            sort_order: sortOrder,
          }),
        },
      );
    }

    uploaded += 1;
    linked += 1;
    console.log(`${args.dryRun ? 'dry' : 'ok'}: ${file} -> ${slug}`);
  }

  console.log(`Tamamlandi. uploaded=${uploaded} linked=${linked} skipped=${skipped} dry_run=${args.dryRun}`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
