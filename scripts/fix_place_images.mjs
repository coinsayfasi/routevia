#!/usr/bin/env node
/**
 * fix_place_images.mjs
 *
 * 1. province slug'larını çeker (bunlar korunur)
 * 2. city_images tablosundan province olmayan tüm kayıtları siler
 *    (yani yanlış şehir görseli almış place kayıtları temizlenir)
 * 3. get_destination_image'ı yeni TR→EN Wikipedia köprüsüyle yeniden çalıştırır
 *
 * Kullanım:
 *   node scripts/fix_place_images.mjs              # dry-run
 *   node scripts/fix_place_images.mjs --apply      # gerçekten temizle + yeniden çek
 *   node scripts/fix_place_images.mjs --apply --province=izmir
 *   node scripts/fix_place_images.mjs --apply --limit=100
 */

import fs from "node:fs";
import path from "node:path";

const ROOT = process.cwd();
const ENV_PATH = path.join(ROOT, ".env");

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

const env = { ...process.env, ...loadEnv(ENV_PATH) };
const SUPABASE_URL = env.SUPABASE_URL;
const SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY ?? env.SUPABASE_PUBLISHABLE_KEY;
const SUPABASE_SERVICE_ROLE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error("SUPABASE_URL, SUPABASE_ANON_KEY ve SUPABASE_SERVICE_ROLE_KEY gerekli.");
  process.exit(1);
}

const args = new Map(
  process.argv.slice(2).map((arg) => {
    const [k, ...rest] = arg.replace(/^--/, "").split("=");
    return [k, rest.length ? rest.join("=") : "true"];
  }),
);
const APPLY = args.get("apply") === "true";
const PROVINCE_FILTER = args.get("province")?.toLowerCase() ?? null;
const LIMIT = Number(args.get("limit") ?? "9999");
const DELAY_MS = Number(args.get("delay-ms") ?? "1500");

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

async function supabaseSelect(table, query = "") {
  const url = `${SUPABASE_URL}/rest/v1/${table}${query ? `?${query}` : ""}`;
  const res = await fetch(url, {
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "count=exact",
    },
  });
  if (!res.ok) throw new Error(`supabase ${table} ${res.status}: ${await res.text()}`);
  return res.json();
}

/** Supabase REST API'nin 1000 satır limitini aşmak için tüm sayfaları çeker */
async function supabaseSelectAll(table, query = "") {
  const PAGE = 1000;
  let offset = 0;
  const all = [];
  while (true) {
    const sep = query ? "&" : "";
    const url = `${SUPABASE_URL}/rest/v1/${table}${query ? `?${query}` : ""}${sep}limit=${PAGE}&offset=${offset}`;
    const res = await fetch(url, {
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
      },
    });
    if (!res.ok) throw new Error(`supabase ${table} ${res.status}: ${await res.text()}`);
    const batch = await res.json();
    if (!batch.length) break;
    all.push(...batch);
    if (batch.length < PAGE) break;
    offset += PAGE;
  }
  return all;
}

async function supabaseDelete(table, filter) {
  const url = `${SUPABASE_URL}/rest/v1/${table}?${filter}`;
  const res = await fetch(url, {
    method: "DELETE",
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
  });
  if (!res.ok) throw new Error(`supabase DELETE ${table} ${res.status}: ${await res.text()}`);
}

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

async function main() {
  console.log("▶ Place görsel düzeltme başlıyor...\n");
  console.log(`  Mode    : ${APPLY ? "APPLY (gerçek)" : "DRY-RUN"}`);
  console.log(`  Province: ${PROVINCE_FILTER ?? "tümü"}`);
  console.log(`  Limit   : ${LIMIT}`);
  console.log(`  Delay   : ${DELAY_MS}ms\n`);

  // 1) Province bilgilerini çek (slug + name) — her ikisi de korunmalı
  const provinces = await supabaseSelect("provinces", "select=slug,name");
  // Provinces tablosundaki slug'lar ("duzce") + slugify(name) ("dzce") her ikisini koru
  const provinceSlugs = new Set([
    ...provinces.map((p) => p.slug),
    ...provinces.map((p) => slugify(p.name)),
  ]);
  console.log(`  Province sayısı: ${provinces.length} → ${provinceSlugs.size} korunan slug`);

  // 2) Tüm places_clean kayıtlarını çek (pagination ile)
  process.stdout.write("  Places çekiliyor...");
  const places = await supabaseSelectAll(
    "places_clean",
    "select=id,name,slug,category,provinces(name,slug)&order=name.asc",
  );
  console.log(` ${places.length} kayıt`);

  // 3) Filtrele
  let tasks = places
    .filter((p) => {
      const provinceSlug = p.provinces?.slug ?? "";
      if (PROVINCE_FILTER && provinceSlug !== PROVINCE_FILTER) return false;
      return true;
    })
    .slice(0, LIMIT);

  console.log(`  İşlenecek place: ${tasks.length}`);

  // Hangi place slug'ları city_images'da var? (sadece province olmayan olanlar silinecek)
  const allCached = await supabaseSelectAll("city_images", "select=city_slug");
  const cachedSlugs = new Set(allCached.map((r) => r.city_slug));
  const toDelete = [...cachedSlugs].filter((s) => !provinceSlugs.has(s));
  console.log(`  city_images toplam: ${cachedSlugs.size}`);
  console.log(`  Silinecek place kaydı: ${toDelete.length} (province olmayanlar)`);
  console.log(`  Korunan province kaydı: ${cachedSlugs.size - toDelete.length}\n`);

  if (!APPLY) {
    console.log("DRY-RUN: Silinecek ilk 20 slug:");
    toDelete.slice(0, 20).forEach((s, i) => console.log(`  ${i + 1}. ${s}`));
    if (toDelete.length > 20) console.log(`  ... ve ${toDelete.length - 20} tane daha`);
    console.log("\nİşlenecek ilk 20 place:");
    tasks.slice(0, 20).forEach((p, i) => {
      const prov = p.provinces?.name ?? "?";
      console.log(`  ${i + 1}. ${p.name} (${prov}) [${p.category}]`);
    });
    console.log("\n--apply ile çalıştır.");
    return;
  }

  // 4) Place kayıtlarını sil (province kayıtlarına dokunma)
  console.log("  ► Place görsel cache temizleniyor...");
  let deleted = 0;
  // Batch delete: IN filter ile (max 100'lük batch)
  const batchSize = 100;
  for (let i = 0; i < toDelete.length; i += batchSize) {
    const batch = toDelete.slice(i, i + batchSize);
    const inFilter = batch.map((s) => `"${s}"`).join(",");
    await supabaseDelete("city_images", `city_slug=in.(${inFilter})`);
    deleted += batch.length;
    process.stdout.write(`\r  Silindi: ${deleted}/${toDelete.length}`);
  }
  console.log(`\n  ✓ ${deleted} kayıt silindi\n`);

  // 5) Yeniden çek (iyileştirilmiş TR→EN Wikipedia köprüsüyle)
  console.log("  ► Görsel yeniden çekiliyor (TR→EN Wikipedia köprüsü aktif)...\n");
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
        const src = result.source === "wikidata" ? "🏛 wikidata" : result.source === "wikipedia" ? "📸 wiki" : "🖼 pexels";
        console.log(`✓ [${src}] ${result.photographer?.slice(0, 50)}`);
        results.ok++;
      }
    } catch (err) {
      console.log(`✗ hata: ${err.message}`);
      results.error++;
    }

    if (i < tasks.length - 1) await sleep(DELAY_MS);
  }

  console.log("\n─── Sonuç ───────────────────────────────");
  console.log(`  ✓ Yeni çekildi (Wikipedia/Pexels): ${results.ok}`);
  console.log(`  ⟳ Zaten vardı                    : ${results.cached}`);
  console.log(`  ✗ Bulunamadı                     : ${results.notFound}`);
  console.log(`  ✗ Hata                           : ${results.error}`);
  console.log(`  Toplam işlenen                   : ${tasks.length}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
