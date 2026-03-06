import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.58.0";

export type DistrictContext = {
  province_id: string;
  province_name: string;
  province_slug: string;
  district_id: string;
  district_name: string;
  district_slug: string;
  lat: number;
  lng: number;
};

type CuratedRow = {
  province_slug: string;
  district_slug?: string;
  province?: string;
  district?: string;
  name: string;
  slug: string;
  category: string;
  lat: number;
  lng: number;
  short_summary: string;
  best_time?: string;
  duration_min?: number;
  tags?: string;
  is_free?: string;
  price_level?: number;
  popularity_score?: number;
  source_url?: string;
  history_tip?: string;
  eat_tip?: string;
  pro_tip?: string;
};

const allowedCategories = new Set([
  "museum",
  "historical",
  "nature",
  "beach",
  "viewpoint",
  "market",
  "cafe",
  "food",
  "activity",
  "lodging",
  "tour",
  "ski",
  "waterfall",
  "canyon",
]);

const GOOGLE_REQ_PER_MIN = Number(Deno.env.get("GOOGLE_REQ_PER_MIN") ?? "30");
const GOOGLE_DAILY_REQUEST_CAP = Number(Deno.env.get("GOOGLE_DAILY_REQUEST_CAP") ?? "5000");
let minuteWindowStart = Date.now();
let minuteWindowCount = 0;
let dayKey = new Date().toISOString().slice(0, 10);
let dayCount = 0;

export function clampRadiusMeters(input?: number): 1000 | 3000 | 10000 {
  const v = Number(input ?? 3000);
  if (v <= 1000) return 1000;
  if (v <= 3000) return 3000;
  return 10000;
}

function categoryFromGoogleTypes(types: string[]): { category: string; tags: string[]; bestTime: string } {
  const t = new Set(types);
  if (t.has("mosque") || t.has("church") || t.has("synagogue") || t.has("place_of_worship")) {
    return { category: "historical", tags: ["culture", "faith", "history"], bestTime: "day" };
  }
  if (t.has("cafe")) return { category: "cafe", tags: ["coffee", "social"], bestTime: "day" };
  if (t.has("restaurant") || t.has("food")) return { category: "food", tags: ["food"], bestTime: "day" };
  if (t.has("lodging") || t.has("hotel")) return { category: "lodging", tags: ["stay"], bestTime: "night" };
  if (t.has("museum")) return { category: "museum", tags: ["history"], bestTime: "day" };
  if (t.has("tourist_attraction")) return { category: "tour", tags: ["attraction"], bestTime: "day" };
  if (t.has("airport")) return { category: "activity", tags: ["airport", "transport", "travel"], bestTime: "day" };
  if (t.has("marina") || t.has("rv_park")) return { category: "tour", tags: ["marina", "coast", "boat"], bestTime: "day" };
  if (t.has("park") || t.has("natural_feature")) return { category: "nature", tags: ["nature"], bestTime: "day" };
  return { category: "viewpoint", tags: ["discover"], bestTime: "sunset" };
}

function categoryFromOsmTags(tags: Record<string, string>): { category: string; tags: string[]; bestTime: string } {
  const tourism = tags.tourism;
  const natural = tags.natural;
  const historic = tags.historic;
  const waterway = tags.waterway;
  const leisure = tags.leisure;
  const amenity = tags.amenity;
  const aeroway = tags.aeroway;
  const harbor = tags.harbour ?? tags.harbor;
  const religion = tags.religion;

  if (amenity === "place_of_worship" || religion) {
    return { category: "historical", tags: ["culture", "faith", "history"], bestTime: "day" };
  }
  if (waterway === "waterfall" || natural === "waterfall") return { category: "waterfall", tags: ["waterfall", "nature"], bestTime: "day" };
  if (natural === "canyon" || tags.geological === "canyon") return { category: "canyon", tags: ["canyon", "nature", "hike"], bestTime: "day" };
  if (natural === "beach") return { category: "beach", tags: ["beach", "nature"], bestTime: "day" };
  if (natural === "bay") return { category: "beach", tags: ["bay", "koy", "coast"], bestTime: "sunset" };
  if (aeroway === "aerodrome" || aeroway === "airport") return { category: "activity", tags: ["airport", "transport"], bestTime: "day" };
  if (amenity === "ferry_terminal" || harbor === "yes" || tourism === "marina") {
    return { category: "tour", tags: ["harbor", "marina", "boat"], bestTime: "day" };
  }
  if (natural === "peak" || tourism === "viewpoint") return { category: "viewpoint", tags: ["view", "sunset"], bestTime: "sunset" };
  if (natural === "wood" || natural === "scrub" || leisure === "park" || leisure === "nature_reserve") {
    return { category: "nature", tags: ["nature", "walk"], bestTime: "day" };
  }
  if (tourism === "museum") return { category: "museum", tags: ["history"], bestTime: "day" };
  if (historic) return { category: "historical", tags: ["history"], bestTime: "day" };
  if (amenity === "marketplace") return { category: "market", tags: ["market"], bestTime: "day" };
  if (tourism === "hotel") return { category: "lodging", tags: ["stay"], bestTime: "night" };
  if (tourism === "attraction") return { category: "tour", tags: ["attraction"], bestTime: "day" };
  return { category: "nature", tags: ["discover"], bestTime: "day" };
}

function isGoogleQualityPass(category: string, rating?: number, reviewCount?: number): boolean {
  const r = Number(rating ?? 0);
  const rc = Number(reviewCount ?? 0);
  if (["food", "cafe", "lodging"].includes(category)) {
    return (r >= 4.3 && rc >= 150) || (r >= 4.5 && rc >= 80);
  }
  return r >= 4.0 && rc >= 50;
}

function googlePriceLevelToInt(value: unknown): number | null {
  if (value == null) return null;
  if (typeof value === "number") return Math.max(0, Math.min(4, Math.floor(value)));
  const normalized = String(value).toUpperCase();
  if (normalized === "PRICE_LEVEL_FREE") return 0;
  if (normalized === "PRICE_LEVEL_INEXPENSIVE") return 1;
  if (normalized === "PRICE_LEVEL_MODERATE") return 2;
  if (normalized === "PRICE_LEVEL_EXPENSIVE") return 3;
  if (normalized === "PRICE_LEVEL_VERY_EXPENSIVE") return 4;
  return null;
}

export async function sleep(ms: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function withTimeout<T>(promise: Promise<T>, timeoutMs: number, label: string): Promise<T> {
  return await Promise.race([
    promise,
    new Promise<T>((_, reject) => setTimeout(() => reject(new Error(`${label}_timeout`)), timeoutMs)),
  ]);
}

async function reserveGoogleQuota(): Promise<boolean> {
  const now = Date.now();
  const nowDay = new Date(now).toISOString().slice(0, 10);
  if (nowDay !== dayKey) {
    dayKey = nowDay;
    dayCount = 0;
  }
  if (dayCount >= GOOGLE_DAILY_REQUEST_CAP) return false;

  if (now - minuteWindowStart >= 60_000) {
    minuteWindowStart = now;
    minuteWindowCount = 0;
  }
  while (minuteWindowCount >= GOOGLE_REQ_PER_MIN) {
    await sleep(300);
    const t = Date.now();
    if (t - minuteWindowStart >= 60_000) {
      minuteWindowStart = t;
      minuteWindowCount = 0;
      break;
    }
  }

  minuteWindowCount += 1;
  dayCount += 1;
  return true;
}

function normalizeName(value: string): string {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function slugifyTr(value: string): string {
  return value
    .toLowerCase()
    .replaceAll("ı", "i")
    .replaceAll("İ", "i")
    .replaceAll("ğ", "g")
    .replaceAll("ü", "u")
    .replaceAll("ş", "s")
    .replaceAll("ö", "o")
    .replaceAll("ç", "c")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function nameSimilarity(a: string, b: string): number {
  const left = new Set(normalizeName(a).split(" ").filter(Boolean));
  const right = new Set(normalizeName(b).split(" ").filter(Boolean));
  if (left.size === 0 || right.size === 0) return 0;
  const inter = [...left].filter((x) => right.has(x)).length;
  const union = new Set([...left, ...right]).size;
  return inter / union;
}

async function fetchJsonWithRetry(url: string, init: RequestInit, retries = 3, timeoutMs = 25_000): Promise<unknown> {
  let error: Error | null = null;
  for (let i = 0; i < retries; i += 1) {
    try {
      const res = await fetch(url, {
        ...init,
        signal: AbortSignal.timeout(timeoutMs),
      });
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${await res.text()}`);
      }
      return await res.json();
    } catch (e) {
      error = e as Error;
      if (i < retries - 1) {
        await sleep(400 * (2 ** i));
      }
    }
  }
  throw error ?? new Error("request failed");
}

function parseCsvLine(line: string): string[] {
  const cols: string[] = [];
  let current = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    const next = i + 1 < line.length ? line[i + 1] : "";
    if (ch === "\"") {
      if (inQuotes && next === "\"") {
        current += "\"";
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (ch === "," && !inQuotes) {
      cols.push(current.trim());
      current = "";
      continue;
    }
    current += ch;
  }
  cols.push(current.trim());
  return cols;
}

function parseBool(value?: string): string | undefined {
  if (!value) return undefined;
  const v = value.trim().toLowerCase();
  if (["true", "1", "yes", "evet"].includes(v)) return "true";
  if (["false", "0", "no", "hayir", "hayır"].includes(v)) return "false";
  return undefined;
}

function parseCsv(content: string): CuratedRow[] {
  const lines = content.split(/\r?\n/).filter((line) => line.trim().length > 0);
  if (lines.length < 2) return [];

  const headers = parseCsvLine(lines[0]).map((x) => x.trim().toLowerCase());
  const rows: CuratedRow[] = [];

  for (let i = 1; i < lines.length; i += 1) {
    const cols = parseCsvLine(lines[i]);
    const row: Record<string, string> = {};
    headers.forEach((h, idx) => {
      row[h] = cols[idx] ?? "";
    });

    const provinceSlug = row.province_slug || slugifyTr(row.province || "");
    const districtSlugRaw = row.district_slug || slugifyTr(row.district || "");
    const districtSlug = districtSlugRaw.length > 0 ? districtSlugRaw : undefined;
    const name = row.name?.trim();
    if (!provinceSlug || !name) continue;
    const slug = (row.slug?.trim() || slugifyTr(`${name}-${districtSlug ?? provinceSlug}`)).slice(0, 120);
    const category = row.category?.trim().toLowerCase() || "tour";
    const lat = Number(row.lat);
    const lng = Number(row.lng);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
    const shortSummaryRaw = row.short_summary || row.short_desc || `${name} için curated öneri.`;
    const tagsRaw = row.tags?.replaceAll("|", ",");
    const inferredBestTime = (tagsRaw?.toLowerCase().includes("sunset") ?? false) ? "sunset" : "day";
    const popularity = row.popularity_score ? Number(row.popularity_score) : 160;

    rows.push({
      province_slug: provinceSlug,
      district_slug: districtSlug,
      province: row.province || undefined,
      district: row.district || undefined,
      name,
      slug,
      category,
      lat,
      lng,
      short_summary: shortSummaryRaw,
      best_time: row.best_time || inferredBestTime,
      duration_min: row.duration_min ? Number(row.duration_min) : undefined,
      tags: tagsRaw || undefined,
      is_free: parseBool(row.is_free),
      price_level: row.price_level ? Number(row.price_level) : undefined,
      popularity_score: Number.isFinite(popularity) ? popularity : 160,
      source_url: row.source_url || undefined,
      history_tip: row.history_tip || undefined,
      eat_tip: row.eat_tip || undefined,
      pro_tip: row.pro_tip || undefined,
    });
  }

  return rows;
}

export async function buildDistrictContext(client: SupabaseClient, districtId: string): Promise<DistrictContext | null> {
  const district = await client
    .from("districts_with_coords")
    .select("id,province_id,name,slug,lat,lng")
    .eq("id", districtId)
    .maybeSingle();

  if (!district.data || district.error) return null;

  const province = await client
    .from("provinces")
    .select("id,name,slug")
    .eq("id", district.data.province_id as string)
    .single();

  if (!province.data || province.error) return null;

  return {
    province_id: district.data.province_id as string,
    province_name: province.data.name as string,
    province_slug: province.data.slug as string,
    district_id: district.data.id as string,
    district_name: district.data.name as string,
    district_slug: district.data.slug as string,
    lat: Number(district.data.lat),
    lng: Number(district.data.lng),
  };
}

function asPoint(lat: number, lng: number): string {
  return `SRID=4326;POINT(${lng} ${lat})`;
}

async function findCanonicalPlace(
  client: SupabaseClient,
  ctx: DistrictContext,
  lat: number,
  lng: number,
  name: string,
): Promise<{ id: string; source_kind: string } | null> {
  const nearby = await client.rpc("nearby_places_core_rpc", {
    p_lat: lat,
    p_lng: lng,
    p_radius_m: 120,
    p_province_id: ctx.province_id,
    p_district_id: ctx.district_id,
    p_categories: null,
    p_tags: null,
    p_free_only: false,
    p_min_rating: null,
    p_limit: 20,
  });
  if (nearby.error) return null;

  const rows = (nearby.data as Record<string, unknown>[] | null) ?? [];
  let best: { id: string; source_kind: string; sim: number } | null = null;
  const normalized = normalizeName(name);
  for (const row of rows) {
    const rowName = String(row.name ?? "");
    const sim = nameSimilarity(name, rowName);
    const distM = Number(row.distance_m ?? 999999);
    const sameNameNear = normalizeName(rowName) == normalized && distM <= 100;
    const isMergeMatch = sameNameNear || (sim >= 0.85 && distM <= 30);
    if (isMergeMatch && (!best || sim > best.sim)) {
      best = { id: String(row.id), source_kind: String(row.source_kind ?? "curated"), sim };
    }
  }
  return best ? { id: best.id, source_kind: best.source_kind } : null;
}

function preferredSource(current: string, incoming: "curated" | "google" | "osm"): "curated" | "google" | "osm" {
  const rank: Record<string, number> = { curated: 3, google: 2, osm: 1 };
  return (rank[current] ?? 0) >= rank[incoming] ? (current as "curated" | "google" | "osm") : incoming;
}

async function upsertGooglePlace(client: SupabaseClient, ctx: DistrictContext, item: Record<string, unknown>): Promise<boolean> {
  const placeId = String(item.id ?? item.place_id ?? "");
  if (!placeId) return false;

  const loc = item.location as { latitude?: number; longitude?: number } | undefined;
  const geometry = item.geometry as { location?: { lat?: number; lng?: number } } | undefined;
  const lat = Number(loc?.latitude ?? geometry?.location?.lat ?? NaN);
  const lng = Number(loc?.longitude ?? geometry?.location?.lng ?? NaN);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;

  const displayName = item.displayName as { text?: string } | undefined;
  const name = String(displayName?.text ?? item.name ?? "").trim();
  if (!name) return false;

  const types = ((item.types as unknown[]) ?? []).map((x) => String(x));
  const mapped = categoryFromGoogleTypes(types);
  const rating = Number(item.rating ?? 0);
  const reviewCount = Number(item.userRatingCount ?? item.user_ratings_total ?? 0);
  if (!isGoogleQualityPass(mapped.category, rating, reviewCount)) return false;

  const slug = `${ctx.province_slug}-${ctx.district_slug}-g-${placeId.slice(0, 20).toLowerCase()}`;
  const shortSummary = `${name} (${ctx.district_name}) bolgesinde kalite esikli Google noktasi.`.slice(0, 160);
  const photoRefs = ((item.photos as Record<string, unknown>[] | undefined) ?? [])
    .map((p) => String(p.name ?? p.photo_reference ?? ""))
    .filter((x) => x.length > 0)
    .slice(0, 5);

  const canonical = await findCanonicalPlace(client, ctx, lat, lng, name);
  if (canonical) {
    const src = preferredSource(canonical.source_kind, "google");
    const { error: mergeError } = await client.from("places").update({
      source_kind: src,
      google_place_id: placeId,
      google_rating: rating,
      google_review_count: reviewCount,
      google_price_level: googlePriceLevelToInt(item.priceLevel ?? item.price_level),
      google_types: types,
      google_photo_refs: photoRefs,
      google_last_sync: new Date().toISOString(),
      source_url: `https://maps.google.com/?q=place_id:${placeId}`,
    }).eq("id", canonical.id);
    return !mergeError;
  }

  const payload = {
    province_id: ctx.province_id,
    district_id: ctx.district_id,
    name,
    slug,
    category: mapped.category,
    geog: asPoint(lat, lng),
    short_summary: shortSummary,
    best_time: mapped.bestTime,
    duration_min: 60,
    tags: Array.from(new Set([...mapped.tags, ...types.slice(0, 3)])),
    popularity_score: Math.max(0, Number(item.user_ratings_total ?? 0)),
    is_free: false,
    source_kind: "google",
    source_url: `https://maps.google.com/?q=place_id:${placeId}`,
    google_place_id: placeId,
    google_rating: rating,
    google_review_count: reviewCount,
    google_price_level: googlePriceLevelToInt(item.priceLevel ?? item.price_level),
    google_types: types,
    google_photo_refs: photoRefs,
    google_last_sync: new Date().toISOString(),
  };

  const existing = await client
    .from("places")
    .select("id")
    .eq("google_place_id", placeId)
    .maybeSingle();

  if (existing.data?.id) {
    const { error: updateErr } = await client
      .from("places")
      .update(payload)
      .eq("id", String(existing.data.id));
    if (updateErr) return false;
    return true;
  }

  const { data, error } = await client
    .from("places")
    .upsert(payload, { onConflict: "province_id,slug" })
    .select("id")
    .single();
  if (error || !data) return false;

  if (photoRefs.length > 0) {
    await client.from("place_media").upsert({
      place_id: data.id,
      storage_path: `public-media/google_refs/${placeId}/${photoRefs[0]}.jpg`,
      source_kind: "google",
      sort_order: 0,
    }, { onConflict: "place_id,storage_path" });
  }
  return true;
}

async function ingestGoogle(
  client: SupabaseClient,
  ctx: DistrictContext,
  googleApiKey: string,
  districtPlaceCount: number,
): Promise<number> {
  const baseQueries = [
    "restaurant",
    "cafe",
    "bakery",
    "local food",
    "breakfast",
    "seafood",
    "traditional food",
    "hotel",
    "boutique hotel",
    "bungalow",
    "museum",
    "tourist attraction",
    "mosque",
    "church",
    "cathedral",
    "basilica",
    "historical place",
    "airport",
    "marina",
    "harbor",
    "ferry terminal",
    "koy",
    "bay",
    "cove",
    "teleferik",
  ];
  const lowDensityQueries = [
    "park",
    "natural feature",
    "beach",
    "waterfall",
    "canyon",
    "castle",
    "viewpoint",
    "cable car",
    "ski resort",
    "beach",
  ];
  const queries = districtPlaceCount < 30
    ? [...baseQueries, ...lowDensityQueries]
    : baseQueries;
  let upserts = 0;

  for (const q of queries) {
    if (!(await reserveGoogleQuota())) break;

    const body: Record<string, unknown> = {
      textQuery: `${q} in ${ctx.district_name}, ${ctx.province_name}, Turkey`,
      languageCode: "tr",
      pageSize: 20,
      locationBias: {
        circle: {
          center: { latitude: ctx.lat, longitude: ctx.lng },
          radius: districtPlaceCount < 30 ? 22_000 : 18_000,
        },
      },
    };

    const json = await fetchJsonWithRetry("https://places.googleapis.com/v1/places:searchText", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": googleApiKey,
        "X-Goog-FieldMask":
          "places.id,places.displayName,places.location,places.types,places.rating,places.userRatingCount,places.priceLevel,places.photos.name",
      },
      body: JSON.stringify(body),
    }, 2, 20_000);
    const results = ((json as { places?: unknown[] }).places ?? []) as Record<string, unknown>[];
    for (const item of results) {
      const ok = await upsertGooglePlace(client, ctx, item);
      if (ok) upserts += 1;
    }

    await sleep(250);
  }

  return upserts;
}

async function upsertOsmPlace(client: SupabaseClient, ctx: DistrictContext, row: Record<string, unknown>): Promise<boolean> {
  const type = String(row.type ?? "");
  const osmId = Number(row.id ?? 0);
  if (!type || !Number.isFinite(osmId) || osmId <= 0) return false;

  const lat = Number(row.lat ?? (row.center as { lat?: number } | undefined)?.lat ?? NaN);
  const lng = Number(row.lon ?? (row.center as { lon?: number } | undefined)?.lon ?? NaN);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;

  const tags = ((row.tags as Record<string, unknown> | undefined) ?? {});
  const tagsObj: Record<string, string> = {};
  for (const [k, v] of Object.entries(tags)) {
    tagsObj[k] = String(v);
  }

  const mapped = categoryFromOsmTags(tagsObj);
  if (!allowedCategories.has(mapped.category)) return false;

  const name = tagsObj.name ?? `${ctx.district_name} ${mapped.category} ${osmId}`;
  const normalizedName = normalizeName(name);
  const genericNames = new Set([
    "park",
    "cocuk parki",
    "cocuk park",
    "semt pazari",
    "semt pazar",
    "pazar",
    "market",
    "parki",
  ]);
  const hasHighValueTags =
    Boolean(tagsObj.tourism) ||
    Boolean(tagsObj.historic) ||
    Boolean(tagsObj.natural) ||
    tagsObj.waterway === "waterfall";
  if (!tagsObj.name) return false;
  if (genericNames.has(normalizedName) && !hasHighValueTags) return false;
  const slug = `${ctx.province_slug}-${ctx.district_slug}-o-${type}-${osmId}`;

  const canonical = await findCanonicalPlace(client, ctx, lat, lng, name);
  if (canonical) {
    const src = preferredSource(canonical.source_kind, "osm");
    const { error: mergeError } = await client.from("places").update({
      source_kind: src,
      osm_type: type,
      osm_id: osmId,
      osm_tags: tagsObj,
      osm_last_sync: new Date().toISOString(),
      source_url: `https://www.openstreetmap.org/${type}/${osmId}`,
    }).eq("id", canonical.id);
    return !mergeError;
  }

  const existing = await client
    .from("places")
    .select("id")
    .eq("osm_type", type)
    .eq("osm_id", osmId)
    .maybeSingle();

  if (existing.data?.id) {
    const { error: updateErr } = await client
      .from("places")
      .update({
        source_kind: "osm",
        source_url: `https://www.openstreetmap.org/${type}/${osmId}`,
        osm_tags: tagsObj,
        osm_last_sync: new Date().toISOString(),
      })
      .eq("id", String(existing.data.id));
    return !updateErr;
  }

  const { error: upsertErr } = await client.from("places").upsert({
    province_id: ctx.province_id,
    district_id: ctx.district_id,
    name,
    slug,
    category: mapped.category,
    geog: asPoint(lat, lng),
    short_summary: `${name} (${ctx.district_name}) OSM kaynakli kesif noktasi.`.slice(0, 160),
    best_time: mapped.bestTime,
    duration_min: 60,
    tags: mapped.tags,
    popularity_score: 35,
    is_free: true,
    source_kind: "osm",
    source_url: `https://www.openstreetmap.org/${type}/${osmId}`,
    osm_type: type,
    osm_id: osmId,
    osm_tags: tagsObj,
    osm_last_sync: new Date().toISOString(),
  }, { onConflict: "province_id,slug" });
  return !upsertErr;
}

async function ingestOsm(
  client: SupabaseClient,
  ctx: DistrictContext,
  overpassUrl: string,
  districtPlaceCount: number,
  forcedRadius?: number,
): Promise<number> {
  const radius = forcedRadius ?? (districtPlaceCount < 20 ? 25000 : districtPlaceCount < 60 ? 18000 : 12000);
  const queryParts = [
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["tourism"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["historic"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["natural"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["waterway"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["leisure"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["amenity"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["aeroway"];`,
    `nwr(around:${radius},${ctx.lat},${ctx.lng})["harbour"];`,
  ];

  const elements: Record<string, unknown>[] = [];
  const seen = new Set<string>();
  for (const part of queryParts) {
    const overpassQuery = `
[out:json][timeout:30];
(
  ${part}
);
out center tags 200;
`;
    const payload = new URLSearchParams({ data: overpassQuery });
    try {
      const raw = await fetchJsonWithRetry(overpassUrl, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: payload.toString(),
      }, 1, 15_000);

      const rows = ((raw as { elements?: unknown[] }).elements ?? []) as Record<string, unknown>[];
      for (const row of rows) {
        const key = `${String(row.type ?? "")}:${String(row.id ?? "")}`;
        if (!seen.has(key)) {
          seen.add(key);
          elements.push(row);
        }
      }
    } catch {
      // Keep ingest resilient: skip failed overpass segment and continue.
    }
    await sleep(120);
  }

  let upserts = 0;
  for (const row of elements) {
    const ok = await upsertOsmPlace(client, ctx, row);
    if (ok) upserts += 1;
  }

  return upserts;
}

async function ingestCurated(client: SupabaseClient, ctx: DistrictContext): Promise<number> {
  const path = `${Deno.cwd()}/data/seed/curated_places.csv`;
  let content = "";
  try {
    content = await Deno.readTextFile(path);
  } catch {
    return 0;
  }

  const rows = parseCsv(content)
    .filter((r) => r.province_slug === ctx.province_slug)
    .filter((r) => !r.district_slug || r.district_slug === ctx.district_slug);

  let upserts = 0;
  const buildBullets = (value?: string, maxLen = 160): string[] => {
    if (!value) return [];
    const clean = value.trim();
    if (!clean) return [];
    return [clean.slice(0, maxLen)];
  };

  for (const row of rows) {
    const category = allowedCategories.has(row.category) ? row.category : "tour";
    const canonical = await findCanonicalPlace(client, ctx, row.lat, row.lng, row.name);
    if (canonical) {
      await client.from("places").update({
        source_kind: "curated",
        district_id: ctx.district_id,
        province_id: ctx.province_id,
        short_summary: row.short_summary.slice(0, 160),
        popularity_score: Math.max(120, Number(row.popularity_score ?? 160)),
        is_published: true,
        price_level: Number.isFinite(Number(row.price_level)) ? Number(row.price_level) : null,
        source_url: row.source_url ?? null,
      }).eq("id", canonical.id);
      await client.from("place_details").upsert({
        place_id: canonical.id,
        history_bullets: buildBullets(row.history_tip),
        eat_drink_bullets: buildBullets(row.eat_tip),
        tips_bullets: buildBullets(row.pro_tip),
      }, { onConflict: "place_id" });
      upserts += 1;
      continue;
    }

    const placeRes = await client.from("places").upsert({
      province_id: ctx.province_id,
      district_id: ctx.district_id,
      name: row.name,
      slug: row.slug,
      category,
      geog: asPoint(row.lat, row.lng),
      short_summary: row.short_summary.slice(0, 160),
      best_time: row.best_time ?? "day",
      duration_min: Math.max(15, Math.min(240, Number(row.duration_min ?? 60))),
      tags: row.tags ? row.tags.split(",").map((x) => x.trim()).filter(Boolean) : [],
      popularity_score: Math.max(120, Number(row.popularity_score ?? 160)),
      is_free: row.is_free === "true",
      price_level: Number.isFinite(Number(row.price_level)) ? Number(row.price_level) : null,
      is_published: true,
      source_kind: "curated",
      source_url: row.source_url ?? null,
    }, { onConflict: "province_id,slug" }).select("id").single();
    if (placeRes.data?.id) {
      await client.from("place_details").upsert({
        place_id: placeRes.data.id,
        history_bullets: buildBullets(row.history_tip),
        eat_drink_bullets: buildBullets(row.eat_tip),
        tips_bullets: buildBullets(row.pro_tip),
      }, { onConflict: "place_id" });
    }
    upserts += 1;
  }

  return upserts;
}

export async function ingestDistrict(
  client: SupabaseClient,
  ctx: DistrictContext,
): Promise<{ google: number; osm: number; curated: number; errors: string[] }> {
  const googleKey = Deno.env.get("GOOGLE_PLACES_API_KEY") ?? "";
  const overpassUrl = Deno.env.get("OVERPASS_URL") ?? "";

  let google = 0;
  let osm = 0;
  let curated = 0;
  const errors: string[] = [];
  const districtCountRes = await client
    .from("places")
    .select("id", { count: "exact", head: true })
    .eq("district_id", ctx.district_id);
  const districtPlaceCount = districtCountRes.count ?? 0;

  if (googleKey) {
    try {
      google = await withTimeout(
        ingestGoogle(client, ctx, googleKey, districtPlaceCount),
        60_000,
        "google",
      );
    } catch (e) {
      errors.push(`google:${(e as Error).message}`);
    }
  }
  if (overpassUrl) {
    try {
      osm = await withTimeout(
        ingestOsm(client, ctx, overpassUrl, districtPlaceCount),
        95_000,
        "osm",
      );
      if (districtPlaceCount + google + osm < 20) {
        const osmPass2 = await withTimeout(
          ingestOsm(client, ctx, overpassUrl, 0, 40_000),
          95_000,
          "osm_pass2",
        );
        osm += osmPass2;
      }
    } catch (e) {
      errors.push(`osm:${(e as Error).message}`);
    }
  }
  try {
    curated = await ingestCurated(client, ctx);
  } catch (e) {
    errors.push(`curated:${(e as Error).message}`);
  }

  return { google, osm, curated, errors };
}
