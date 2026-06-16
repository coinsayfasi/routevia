#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const ROOT = process.cwd();
const MUST_SEE_PATH = path.join(ROOT, "apps/mobile/lib/src/data/must_see_places.dart");
const FALLBACK_PROVINCES_PATH = path.join(
  ROOT,
  "apps/mobile/lib/src/data/fallback_provinces.dart",
);
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

const env = { ...loadEnv(ENV_PATH), ...process.env };
const SUPABASE_URL = env.SUPABASE_URL;
const SUPABASE_ANON_KEY = env.SUPABASE_ANON_KEY ?? env.SUPABASE_PUBLISHABLE_KEY;
const SUPABASE_SERVICE_ROLE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error(
    "SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY are required.",
  );
}

const args = new Map(
  process.argv.slice(2).map((arg) => {
    const [k, ...rest] = arg.replace(/^--/, "").split("=");
    return [k, rest.length ? rest.join("=") : "true"];
  }),
);
const APPLY = args.get("apply") === "true";
const PROVINCE_ONLY = args.get("province")?.toLowerCase() ?? null;
const LIMIT = Number(args.get("limit") ?? "9999");
const DELAY_MS = Number(args.get("delay-ms") ?? "1200");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function normalizeText(value) {
  return String(value ?? "")
    .toLowerCase()
    .replaceAll("ç", "c")
    .replaceAll("ğ", "g")
    .replaceAll("ı", "i")
    .replaceAll("ö", "o")
    .replaceAll("ş", "s")
    .replaceAll("ü", "u")
    .replace(/[^a-z0-9]+/g, "")
    .trim();
}

function slugify(value) {
  return String(value ?? "")
    .toLowerCase()
    .replaceAll("ç", "c")
    .replaceAll("ğ", "g")
    .replaceAll("ı", "i")
    .replaceAll("ö", "o")
    .replaceAll("ş", "s")
    .replaceAll("ü", "u")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");
}

function titleizeKeyword(keyword) {
  return keyword
    .split(/\s+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

const kCategoryOverrides = {
  kayakoy: "historical",
  "kayaköy": "historical",
  saklikent: "nature",
  kaunos: "historical",
  knidos: "historical",
  labranda: "historical",
  babadag: "viewpoint",
  "babadağ": "viewpoint",
  azmak: "nature",
  gocek: "beach",
};

function inferCategory(keyword) {
  const n = normalizeText(keyword);
  if (kCategoryOverrides[n]) return kCategoryOverrides[n];
  if (
    [
      "plaj",
      "koyu",
      "koy",
      "oludeniz",
      "iztuzu",
      "kaputas",
      "kabak",
      "ada",
      "gobun",
      "gocek",
    ].some((x) => n.includes(x))
  ) {
    return "beach";
  }
  if (
    [
      "muze",
      "muzesi",
      "sarayi",
      "manastiri",
      "antik",
      "harabeleri",
      "kalesi",
      "kale",
      "kaunos",
      "labranda",
      "knidos",
      "hamam",
      "kilise",
      "tlos",
      "kayakoy",
      "kayakoyu",
    ].some((x) => n.includes(x))
  ) {
    return "historical";
  }
  if (
    [
      "vadi",
      "vadisi",
      "kanyon",
      "selalesi",
      "magara",
      "golu",
      "gol",
      "orman",
      "latmos",
    ].some((x) => n.includes(x))
  ) {
    return "nature";
  }
  if (["teras", "manzara", "tepe", "kule", "babadag"].some((x) => n.includes(x))) {
    return "viewpoint";
  }
  return "historical";
}

function inferBestTime(category) {
  if (category === "beach") return "day";
  if (category === "viewpoint") return "sunset";
  return "day";
}

function inferDuration(category) {
  if (category === "beach") return 120;
  if (category === "nature") return 90;
  if (category === "viewpoint") return 60;
  return 75;
}

function inferSummary(name, provinceName, districtName, category) {
  const basis =
    category === "beach"
      ? `${name}, ${districtName || provinceName} tarafinda mutlaka gorulmesi gereken ikonik bir sahil ve kesif noktasi.`
      : category === "nature"
        ? `${name}, ${districtName || provinceName} bolgesinde one cikan doga ve gezi duraklarindan biridir.`
        : category === "viewpoint"
          ? `${name}, ${districtName || provinceName} civarinda manzara ve fotograf icin one cikan ikonik bir noktadir.`
          : `${name}, ${districtName || provinceName} tarafinda one cikan ikonik ve tarihsel gezi duraklarindan biridir.`;
  return basis.slice(0, 160);
}

const kSearchAliases = {
  "kabak koyu": ["kabak beach", "kabak plaji", "kabak koyu"],
  "sedir adasi": ["sedir island", "kleopatra adasi", "cleopatra island"],
  "saklikent": ["saklikent kanyonu", "saklikent canyon", "saklikent"],
  "iztuzu plaji": ["iztuzu beach", "iztuzu plaji"],
  "babadağ": ["babadağ", "babadag", "babadağ teleferik"],
};

function parseMustSeeFile(contents) {
  const lines = contents.split(/\r?\n/);
  const provinceMap = new Map();
  const districtMap = new Map();

  let mode = null;
  let currentProvince = null;
  let currentDistrict = null;
  let collecting = [];

  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (line.startsWith("const Map<String, List<String>> kMustSeePlaceKeywordsByProvince")) {
      mode = "province";
      continue;
    }
    if (line.startsWith("const Map<String, Map<String, List<String>>> kMustSeePlaceKeywordsByDistrict")) {
      mode = "district-root";
      continue;
    }
    if (!mode) continue;
    if (line === "};") {
      if (mode === "province" || mode === "district-root") {
        mode = null;
      }
      continue;
    }

    if (mode === "province") {
      const inline = line.match(/^'([^']+)': \[(.*)\],?$/);
      if (inline) {
        const provinceSlug = inline[1];
        const values = [...inline[2].matchAll(/'([^']+)'/g)].map((m) => m[1]);
        provinceMap.set(provinceSlug, values);
        continue;
      }
      const start = line.match(/^'([^']+)': \[$/);
      if (start) {
        currentProvince = start[1];
        collecting = [];
        continue;
      }
      if (currentProvince) {
        if (line.startsWith("],")) {
          provinceMap.set(currentProvince, [...collecting]);
          currentProvince = null;
          collecting = [];
          continue;
        }
        for (const match of line.matchAll(/'([^']+)'/g)) {
          collecting.push(match[1]);
        }
      }
      continue;
    }

    if (mode === "district-root") {
      const provinceStart = line.match(/^'([^']+)': \{$/);
      if (provinceStart) {
        currentProvince = provinceStart[1];
        districtMap.set(currentProvince, new Map());
        mode = "district";
        continue;
      }
      continue;
    }

    if (mode === "district") {
      if (line === "},") {
        currentProvince = null;
        currentDistrict = null;
        collecting = [];
        mode = "district-root";
        continue;
      }
      const inline = line.match(/^'([^']+)': \[(.*)\],?$/);
      if (inline) {
        const districtSlug = inline[1];
        const values = [...inline[2].matchAll(/'([^']+)'/g)].map((m) => m[1]);
        districtMap.get(currentProvince).set(districtSlug, values);
        continue;
      }
      const districtStart = line.match(/^'([^']+)': \[$/);
      if (districtStart) {
        currentDistrict = districtStart[1];
        collecting = [];
        continue;
      }
      if (currentDistrict) {
        if (line.startsWith("],")) {
          districtMap.get(currentProvince).set(currentDistrict, [...collecting]);
          currentDistrict = null;
          collecting = [];
          continue;
        }
        for (const match of line.matchAll(/'([^']+)'/g)) {
          collecting.push(match[1]);
        }
      }
    }
  }

  return { provinceMap, districtMap };
}

function parseFallbackProvinces(contents) {
  const map = new Map();
  let currentSlug = null;
  let currentName = null;
  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();
    const slugMatch = line.match(/^'slug': '([^']+)'/);
    if (slugMatch) {
      currentSlug = slugMatch[1];
      if (currentName) {
        map.set(currentSlug, currentName);
        currentSlug = null;
        currentName = null;
      }
      continue;
    }
    const nameMatch = line.match(/^'name': '([^']+)'/);
    if (nameMatch) {
      currentName = nameMatch[1];
      if (currentSlug) {
        map.set(currentSlug, currentName);
        currentSlug = null;
        currentName = null;
      }
    }
  }
  return map;
}

async function geocodeKeyword({ keyword, provinceName, districtName }) {
  const provinceNorm = normalizeText(provinceName);
  const districtNorm = normalizeText(districtName ?? "");
  const variants = [
    keyword,
    ...(kSearchAliases[normalizeText(keyword)] ?? []),
  ];
  for (const variant of variants) {
    const query = districtName
      ? `${titleizeKeyword(variant)}, ${districtName}, ${provinceName}, Türkiye`
      : `${titleizeKeyword(variant)}, ${provinceName}, Türkiye`;
    const url =
      "https://nominatim.openstreetmap.org/search?" +
      new URLSearchParams({
        q: query,
        format: "jsonv2",
        addressdetails: "1",
        countrycodes: "tr",
        limit: "5",
      }).toString();
    const res = await fetch(url, {
      headers: {
        "User-Agent": "RouteviaMustSeeBackfill/1.0 (routevia@tabserve.com.tr)",
        Accept: "application/json",
      },
    });
    if (!res.ok) throw new Error(`nominatim ${res.status}`);
    const items = await res.json();
    const keywordNorm = normalizeText(variant);
    const match = (items ?? []).find((item) => {
      const addr = item.address ?? {};
      const state = normalizeText(
        addr.state ?? addr.province ?? addr.region ?? addr.county ?? "",
      );
      const locality = normalizeText(
        addr.city_district ??
          addr.town ??
          addr.municipality ??
          addr.county ??
          addr.state_district ??
          addr.suburb ??
          addr.village ??
          "",
      );
      const display = normalizeText(item.display_name ?? "");
      const name = normalizeText(item.name ?? "");
      const provinceOk = state.includes(provinceNorm) || display.includes(provinceNorm);
      const districtOk =
        !districtNorm ||
        locality.includes(districtNorm) ||
        display.includes(districtNorm);
      const keywordOk =
        name.includes(keywordNorm) ||
        display.includes(keywordNorm) ||
        keywordNorm.includes(name);
      return provinceOk && districtOk && keywordOk;
    });
    if (match) return match;
  }
  return null;
}

function sqlString(value) {
  return `'${String(value ?? "").replaceAll("'", "''")}'`;
}

function sqlArray(values) {
  const items = values.map((value) => sqlString(value)).join(",");
  return `array[${items}]::text[]`;
}

function buildPlaceInsertSql({
  provinceSlug,
  districtSlug,
  provinceName,
  districtName,
  keyword,
  lat,
  lng,
}) {
  const category = inferCategory(keyword);
  const name = titleizeKeyword(keyword);
  const slug = slugify(keyword);
  const tags = ["must-see", "iconic", provinceName.toLowerCase(), ...(districtName ? [districtName.toLowerCase()] : [])];
  const summary = inferSummary(name, provinceName, districtName, category);
  const verifiedAt = new Date().toISOString();
  return `
with upserted as (
  insert into public.places_clean (
    province_id,
    district_id,
    name,
    slug,
    category,
    geog,
    short_summary,
    best_time,
    duration_min,
    tags,
    popularity_score,
    coordinate_source,
    coordinate_verified_at,
    coordinate_verified_by
  )
  values (
    (select id from public.provinces where slug = ${sqlString(provinceSlug)} limit 1),
    ${
      districtSlug
        ? `(select d.id from public.districts d join public.provinces p on p.id = d.province_id where p.slug = ${sqlString(provinceSlug)} and d.slug = ${sqlString(districtSlug)} limit 1)`
        : "null"
    },
    ${sqlString(name)},
    ${sqlString(slug)},
    ${sqlString(category)}::public.place_category,
    ${sqlString(`SRID=4326;POINT(${lng} ${lat})`)}::geography,
    ${sqlString(summary)},
    ${sqlString(inferBestTime(category))}::public.best_time,
    ${inferDuration(category)},
    ${sqlArray(tags)},
    96,
    'admin_verified'::public.coordinate_source_kind,
    ${sqlString(verifiedAt)}::timestamptz,
    'must_see_backfill_script'
  )
  on conflict (province_id, slug) do update
  set
    popularity_score = greatest(public.places_clean.popularity_score, excluded.popularity_score),
    tags = array(
      select distinct tag
      from unnest(coalesce(public.places_clean.tags, '{}'::text[]) || excluded.tags) as tag
    )
  returning id
)
insert into public.place_details_clean (
  place_id,
  history_bullets,
  eat_drink_bullets,
  tips_bullets
)
select id, array[]::text[], array[]::text[], array[]::text[]
from upserted
on conflict (place_id) do nothing;`.trim();
}

function buildPlacePayload({
  provinceSlug,
  districtSlug,
  provinceName,
  districtName,
  keyword,
  lat,
  lng,
}) {
  const category = inferCategory(keyword);
  const name = titleizeKeyword(keyword);
  return {
    province_slug: provinceSlug,
    district_slug: districtSlug,
    name,
    slug: slugify(keyword),
    category,
    lat,
    lng,
    short_summary: inferSummary(name, provinceName, districtName, category),
    best_time: inferBestTime(category),
    duration_min: inferDuration(category),
    tags: [
      "must-see",
      "iconic",
      normalizeText(provinceName),
      ...(districtName ? [normalizeText(districtName)] : []),
    ],
    popularity_score: 96,
    history_bullets: [],
    eat_drink_bullets: [],
    tips_bullets: [],
    media_paths: [],
  };
}

async function invokeAdminPlaceUpsert(payload) {
  const res = await fetch(`${SUPABASE_URL}/functions/v1/admin_place_upsert`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      "x-worker-secret": SUPABASE_SERVICE_ROLE_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    throw new Error(`admin_place_upsert ${res.status}: ${await res.text()}`);
  }
  return res.json();
}

async function main() {
  const source = fs.readFileSync(MUST_SEE_PATH, "utf8");
  const fallbackProvinces = parseFallbackProvinces(
    fs.readFileSync(FALLBACK_PROVINCES_PATH, "utf8"),
  );
  const { provinceMap, districtMap } = parseMustSeeFile(source);

  const tasks = [];
  for (const [provinceSlug, keywords] of provinceMap.entries()) {
    if (PROVINCE_ONLY && PROVINCE_ONLY !== provinceSlug) continue;
    for (const keyword of keywords) {
      tasks.push({ provinceSlug, districtSlug: null, keyword });
    }
  }
  for (const [provinceSlug, districtEntries] of districtMap.entries()) {
    if (PROVINCE_ONLY && PROVINCE_ONLY !== provinceSlug) continue;
    for (const [districtSlug, keywords] of districtEntries.entries()) {
      for (const keyword of keywords) {
        tasks.push({ provinceSlug, districtSlug, keyword });
      }
    }
  }

  const results = [];
  const sqlStatements = [];
  let processed = 0;
  for (const task of tasks) {
    if (processed >= LIMIT) break;
    processed += 1;
    const provinceName = fallbackProvinces.get(task.provinceSlug);
    if (!provinceName) {
      results.push({ ...task, status: "missing_province" });
      continue;
    }
    const districtName =
      task.districtSlug == null ? null : titleizeKeyword(task.districtSlug);
    const geo = await geocodeKeyword({
      keyword: task.keyword,
      provinceName,
      districtName,
    }).catch((error) => ({ error: error.message }));
    if (!geo || geo.error) {
      results.push({ ...task, status: "manual_review", reason: geo?.error ?? "geocode_failed" });
      await sleep(DELAY_MS);
      continue;
    }
    if (!APPLY) {
      results.push({
        ...task,
        status: "prepared",
        lat: Number(geo.lat),
        lng: Number(geo.lon),
        displayName: geo.display_name,
      });
      await sleep(DELAY_MS);
      continue;
    }
    const payload = buildPlacePayload({
      provinceSlug: task.provinceSlug,
      districtSlug: task.districtSlug,
      provinceName,
      districtName,
      keyword: task.keyword,
      lat: Number(geo.lat),
      lng: Number(geo.lon),
    });
    sqlStatements.push(
      buildPlaceInsertSql({
        provinceSlug: task.provinceSlug,
        districtSlug: task.districtSlug,
        provinceName,
        districtName,
        keyword: task.keyword,
        lat: Number(geo.lat),
        lng: Number(geo.lon),
      }),
    );
    const upsert = await invokeAdminPlaceUpsert(payload);
    results.push({
      ...task,
      status: "inserted",
      placeId: upsert.place_id,
      lat: Number(geo.lat),
      lng: Number(geo.lon),
    });
    await sleep(DELAY_MS);
  }

  let outputFile = null;
  if (APPLY && sqlStatements.length > 0) {
    const stamp = new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14);
    outputFile = path.join(
      ROOT,
      "supabase/migrations",
      `${stamp}_must_see_backfill_generated.sql`,
    );
    const sql = `${sqlStatements.join("\n\n")}\n`;
    fs.writeFileSync(outputFile, sql);
  }

  const summary = results.reduce((acc, item) => {
    acc[item.status] = (acc[item.status] ?? 0) + 1;
    return acc;
  }, {});
  console.log(JSON.stringify({ apply: APPLY, total: results.length, summary, outputFile, results }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
