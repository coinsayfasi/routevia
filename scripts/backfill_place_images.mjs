#!/usr/bin/env node
/**
 * backfill_place_images.mjs
 *
 * Tüm places_clean kayıtları için Wikipedia/Pexels görsellerini
 * city_images cache tablosuna önceden doldurur.
 *
 * Kullanım:
 *   node scripts/backfill_place_images.mjs              # dry-run: kaç place var göster
 *   node scripts/backfill_place_images.mjs --apply      # gerçekten çek
 *   node scripts/backfill_place_images.mjs --apply --province=antalya
 *   node scripts/backfill_place_images.mjs --apply --limit=50
 *   node scripts/backfill_place_images.mjs --apply --only-missing  # sadece cache'de olmayanları
 *
 * Notlar:
 *   - Wikipedia birincil kaynak, Pexels fallback (get_destination_image mantığıyla aynı)
 *   - Varsayılan delay: 1500ms (Wikipedia + Pexels rate limit için yeterli)
 *   - ~1000 place için ~25 dakika sürer
 */

import fs from "node:fs";
import path from "node:path";

const ROOT = process.cwd();
const ENV_PATH = path.join(ROOT, ".env");

// ─── Env ──────────────────────────────────────────────────────────────────────

function loadEnv(filePath) {
  const env = {};
  if (!fs.existsSync(filePath)) return env;
  for (const line of fs.readFileSync(filePath, "utf8").split(/\r?\n/)) {
    if (!line || line.trim().startsWith("#") || !line.includes("=")) continue;
    const idx = line.indexOf("=");
    const key = line.slice(0, idx).trim();
    let value = line.slice(idx + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    env[key] = value;
  }
  return env;
}

// .env file values take precedence over shell environment
const env = { ...process.env, ...loadEnv(ENV_PATH) };
const SUPABASE_URL = env.SUPABASE_URL;
const SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY ?? env.SUPABASE_PUBLISHABLE_KEY;
const SUPABASE_SERVICE_ROLE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("SUPABASE_URL, SUPABASE_ANON_KEY ve SUPABASE_SERVICE_ROLE_KEY gerekli.");
  process.exit(1);
}

// ─── Args ─────────────────────────────────────────────────────────────────────

const args = new Map(
  process.argv.slice(2).map((arg) => {
    const [k, ...rest] = arg.replace(/^--/, "").split("=");
    return [k, rest.length ? rest.join("=") : "true"];
  }),
);
const APPLY = args.get("apply") === "true";
const PROVINCE_FILTER = args.get("province")?.toLowerCase() ?? null;
const LIMIT = Number(args.get("limit") ?? "9999");
const ONLY_MISSING = args.get("only-missing") === "true";
const DELAY_MS = Number(args.get("delay-ms") ?? "1500");

// ─── Helpers ──────────────────────────────────────────────────────────────────

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function slugify(str) {
  return String(str ?? "")
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "")
    .slice(0, 80);
}

// ─── Supabase REST ────────────────────────────────────────────────────────────

async function supabaseSelect(table, query = "") {
  // PostgREST sayfa başına en fazla 1000 satır döner; Range ile TÜMÜNÜ çek.
  const pageSize = 1000;
  let from = 0;
  const all = [];
  for (;;) {
    const url = `${SUPABASE_URL}/rest/v1/${table}${query ? `?${query}` : ""}`;
    const res = await fetch(url, {
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
        Range: `${from}-${from + pageSize - 1}`,
      },
    });
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`supabase ${table} ${res.status}: ${text}`);
    }
    const batch = await res.json();
    all.push(...batch);
    if (batch.length < pageSize) break;
    from += pageSize;
  }
  return all;
}

// ─── get_destination_image edge function ──────────────────────────────────────

async function fetchDestinationImage({ city, place_name, category }) {
  const res = await fetch(
    `${SUPABASE_URL}/functions/v1/get_destination_image`,
    {
      method: "POST",
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ city, place_name, category }),
    },
  );
  const data = await res.json();
  if (!res.ok) return { ok: false, error: data?.error ?? `HTTP ${res.status}` };
  return { ok: true, ...data };
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log("▶ Place görseli backfill başlıyor...\n");
  console.log(`  Mode    : ${APPLY ? "APPLY (gerçek)" : "DRY-RUN"}`);
  console.log(`  Province: ${PROVINCE_FILTER ?? "tümü"}`);
  console.log(`  Limit   : ${LIMIT}`);
  console.log(`  Missing : ${ONLY_MISSING ? "sadece cache'siz" : "hepsi"}`);
  console.log(`  Delay   : ${DELAY_MS}ms\n`);

  // 1) Tüm places_clean + province adlarını çek
  const places = await supabaseSelect(
    "places_clean",
    "select=id,name,slug,category,provinces(name,slug)&order=name.asc",
  );

  console.log(`  Toplam place: ${places.length}`);

  // 2) Cache'deki mevcut slug'ları çek (only-missing için)
  let cachedSlugs = new Set();
  if (ONLY_MISSING) {
    const cached = await supabaseSelect("city_images", "select=city_slug");
    cachedSlugs = new Set(cached.map((r) => r.city_slug));
    console.log(`  Cache'de mevcut: ${cachedSlugs.size}`);
  }

  // 3) Filtrele + ÖNCELİK SIRALA (çok görüntülenen turistik iller önce ısınsın)
  const PRIORITY_PROVINCES = [
    "istanbul", "antalya", "izmir", "mugla", "nevsehir", "ankara", "aydin",
    "bursa", "balikesir", "denizli", "trabzon", "canakkale", "konya",
    "gaziantep", "mardin", "edirne", "eskisehir", "kayseri", "sanliurfa",
    "kocaeli", "tekirdag", "hatay", "samsun", "adana", "mersin", "kastamonu",
    "rize", "artvin", "bolu", "yalova", "afyonkarahisar", "isparta",
  ];
  const provincePriority = (slug) => {
    const i = PRIORITY_PROVINCES.indexOf(slug);
    return i < 0 ? 999 : i;
  };
  let tasks = places
    .filter((p) => {
      const provinceSlug = p.provinces?.slug ?? "";
      if (PROVINCE_FILTER && provinceSlug !== PROVINCE_FILTER) return false;
      if (ONLY_MISSING && cachedSlugs.has(slugify(p.name))) return false;
      return true;
    })
    .sort((a, b) => {
      const pa = provincePriority(a.provinces?.slug ?? "");
      const pb = provincePriority(b.provinces?.slug ?? "");
      if (pa !== pb) return pa - pb;
      return (a.name ?? "").localeCompare(b.name ?? "", "tr");
    })
    .slice(0, LIMIT);

  console.log(`  İşlenecek: ${tasks.length}\n`);

  if (!APPLY) {
    console.log("DRY-RUN: İşlenecek ilk 20 place:");
    tasks.slice(0, 20).forEach((p, i) => {
      const prov = p.provinces?.name ?? "?";
      console.log(`  ${i + 1}. ${p.name} (${prov}) [${p.category}] slug=${slugify(p.name)}`);
    });
    if (tasks.length > 20) console.log(`  ... ve ${tasks.length - 20} tane daha`);
    console.log("\n--apply ile çalıştır.");
    return;
  }

  // 4) Her place için görsel çek
  const results = { ok: 0, cached: 0, notFound: 0, error: 0 };

  for (let i = 0; i < tasks.length; i++) {
    const place = tasks[i];
    const provinceName = place.provinces?.name ?? "";
    const prefix = `[${i + 1}/${tasks.length}]`;

    process.stdout.write(`${prefix} ${place.name} (${provinceName})... `);

    try {
      const result = await fetchDestinationImage({
        city: provinceName,
        place_name: place.name,
        category: place.category,
      });

      if (!result.ok) {
        console.log(`✗ bulunamadı (${result.error})`);
        results.notFound++;
      } else if (result.source === "cache") {
        console.log(`⟳ zaten cache'de`);
        results.cached++;
      } else {
        console.log(`✓ [${result.source}] ${result.image_url?.slice(0, 60)}...`);
        results.ok++;
      }
    } catch (err) {
      console.log(`✗ hata: ${err.message}`);
      results.error++;
    }

    if (i < tasks.length - 1) await sleep(DELAY_MS);
  }

  console.log("\n─── Sonuç ───────────────────────────────");
  console.log(`  ✓ Yeni çekildi : ${results.ok}`);
  console.log(`  ⟳ Zaten vardı  : ${results.cached}`);
  console.log(`  ✗ Bulunamadı   : ${results.notFound}`);
  console.log(`  ✗ Hata         : ${results.error}`);
  console.log(`  Toplam         : ${tasks.length}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
