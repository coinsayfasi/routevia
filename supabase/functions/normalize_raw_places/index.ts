import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { buildDistrictContext } from "../_shared/ingest.ts";
import { getServiceClient, requireAdminOrWorker } from "../_shared/client.ts";

type Payload = {
  district_id: string;
  limit?: number;
  auto_approve_safe?: boolean;
};

type RawRow = {
  id: string;
  source: string;
  source_place_id: string;
  name: string;
  lat: number;
  lng: number;
  province_id: string;
  district_id: string;
  types: string[] | null;
  rating: number | null;
  user_ratings_total: number | null;
  price_level: number | null;
  raw_hash: string;
};

type Normalized = {
  category: "nature" | "historical" | "viewpoint" | "beach" | "activity" | "food" | "cafe" | "lodging" | "museum" | "tour";
  tags: string[];
  short_desc: string;
  history_tip: string;
  eat_tip: string;
  pro_tip: string;
  score_boost: number;
};

const GENERIC_BLOCKLIST = new Set([
  "park",
  "cocuk parki",
  "çocuk parki",
  "semt pazari",
  "semt pazarı",
  "pazar",
  "market",
  "parki",
]);

function normalizeName(value: string): string {
  return value
    .toLowerCase()
    .replaceAll("ı", "i")
    .replaceAll("ğ", "g")
    .replaceAll("ü", "u")
    .replaceAll("ş", "s")
    .replaceAll("ö", "o")
    .replaceAll("ç", "c")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function haversineMeters(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371e3;
  const toRad = (v: number) => (v * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function jaccardWords(a: string, b: string): number {
  const left = new Set(normalizeName(a).split(" ").filter(Boolean));
  const right = new Set(normalizeName(b).split(" ").filter(Boolean));
  if (!left.size || !right.size) return 0;
  let inter = 0;
  for (const w of left) if (right.has(w)) inter += 1;
  return inter / new Set([...left, ...right]).size;
}

function mapCategory(types: string[]): Normalized["category"] {
  const t = new Set(types.map((x) => String(x).toLowerCase()));
  if (t.has("museum")) return "museum";
  if (t.has("historical_landmark") || t.has("place_of_worship") || t.has("mosque") || t.has("church") || t.has("synagogue")) return "historical";
  if (t.has("beach") || t.has("bay")) return "beach";
  if (t.has("tourist_attraction")) return "tour";
  if (t.has("park") || t.has("natural_feature") || t.has("national_park") || t.has("waterfall") || t.has("canyon")) return "nature";
  if (t.has("viewpoint") || t.has("point_of_interest")) return "viewpoint";
  if (t.has("restaurant") || t.has("meal_takeaway")) return "food";
  if (t.has("cafe") || t.has("bakery")) return "cafe";
  if (t.has("lodging") || t.has("hotel") || t.has("motel")) return "lodging";
  return "activity";
}

function buildTemplateHap(row: RawRow, districtName: string): Normalized {
  const types = row.types ?? [];
  const category = mapCategory(types);
  const tags = Array.from(new Set([
    category,
    ...(types.slice(0, 4).map((x) => String(x).toLowerCase())),
    (row.rating ?? 0) >= 4.5 ? "top-rated" : "",
    category === "viewpoint" ? "sunset" : "",
  ].filter(Boolean)));

  const short_desc = `${row.name}, ${districtName} bölgesinde öne çıkan ${category} noktası.`.slice(0, 160);
  const history_tip = category === "historical" || category === "museum"
    ? "Tarih detaylarını girişteki bilgi panolarından okuyup ana rota ile gez."
    : "Bölgenin bağlamını öğrenmek için kısa bir ön araştırma deneyimi iyileştirir.";
  const eat_tip = ["food", "cafe"].includes(category)
    ? "Yoğun saatlerden önce gitmek servis hızını artırır."
    : "Yakın çevrede yerel ve uygun fiyatlı seçenekleri tercih et.";
  const pro_tip = tags.includes("sunset")
    ? "Gün batımından 30-45 dakika önce konumlan; rüzgar için hafif üstlük al."
    : "Kalabalıktan kaçınmak için sabah erken veya hafta içi ziyaret et.";

  const score_boost = (row.rating ?? 0) >= 4.6 && (row.user_ratings_total ?? 0) >= 250 ? 8 :
    (row.rating ?? 0) >= 4.4 && (row.user_ratings_total ?? 0) >= 120 ? 5 : 0;

  return {
    category,
    tags,
    short_desc,
    history_tip: history_tip.slice(0, 160),
    eat_tip: eat_tip.slice(0, 160),
    pro_tip: pro_tip.slice(0, 160),
    score_boost,
  };
}

async function maybeOpenAiHap(row: RawRow, districtName: string): Promise<Normalized | null> {
  const apiKey = Deno.env.get("OPENAI_API_KEY") ?? "";
  if (!apiKey) return null;

  const model = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";
  const prompt = `Classify and generate compact Turkish travel tips.\nPlace: ${row.name}\nDistrict: ${districtName}\nTypes: ${(row.types ?? []).join(",")}\nRating: ${row.rating ?? "n/a"}\nReviews: ${row.user_ratings_total ?? "n/a"}\nReturn ONLY JSON with keys: category,tags,short_desc,history_tip,eat_tip,pro_tip,score_boost. Category one of: nature,historical,viewpoint,beach,activity,food,cafe,lodging,museum,tour.`;

  try {
    const res = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        input: prompt,
        text: { format: { type: "json_object" } },
      }),
      signal: AbortSignal.timeout(15_000),
    });
    if (!res.ok) return null;
    const json = await res.json() as Record<string, unknown>;
    const outputText = String((json.output_text ?? "")).trim();
    if (!outputText) return null;
    const parsed = JSON.parse(outputText) as Partial<Normalized>;
    const category = parsed.category;
    const validCategory = ["nature","historical","viewpoint","beach","activity","food","cafe","lodging","museum","tour"].includes(String(category));
    if (!validCategory) return null;
    return {
      category: String(parsed.category) as Normalized["category"],
      tags: Array.isArray(parsed.tags) ? parsed.tags.map((x) => String(x)).slice(0, 12) : [],
      short_desc: String(parsed.short_desc ?? "").slice(0, 160),
      history_tip: String(parsed.history_tip ?? "").slice(0, 160),
      eat_tip: String(parsed.eat_tip ?? "").slice(0, 160),
      pro_tip: String(parsed.pro_tip ?? "").slice(0, 160),
      score_boost: Number(parsed.score_boost ?? 0),
    };
  } catch {
    return null;
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrWorker(authHeader, req.headers.get("x-worker-secret"));

    const body = (await req.json().catch(() => ({}))) as Payload;
    if (!body.district_id) return jsonResponse({ error: "district_id required" }, 400);

    const limit = Math.max(10, Math.min(1000, Number(body.limit ?? 300)));
    const autoApproveSafe = Boolean(body.auto_approve_safe);

    const service = getServiceClient();
    const district = await buildDistrictContext(service, body.district_id);
    if (!district) return jsonResponse({ error: "district_not_found" }, 404);

    const publishedCountRes = await service
      .from("places")
      .select("id", { count: "exact", head: true })
      .eq("district_id", district.district_id)
      .eq("is_published", true);
    const districtPublished = publishedCountRes.count ?? 0;

    const { data, error } = await service
      .from("raw_places")
      .select("id,source,source_place_id,name,lat,lng,province_id,district_id,types,rating,user_ratings_total,price_level,raw_hash")
      .eq("district_id", district.district_id)
      .order("rating", { ascending: false, nullsFirst: false })
      .order("user_ratings_total", { ascending: false, nullsFirst: false })
      .limit(limit);

    if (error) return jsonResponse({ error: error.message }, 500);

    const raws = (data ?? []) as RawRow[];
    const candidateMap = new Map<string, { name: string; lat: number; lng: number }>();

    let drafts = 0;
    let skipped = 0;
    let merged = 0;
    let approved = 0;
    const safeApproveIds: string[] = [];

    for (const row of raws) {
      const existingCandidate = await service
        .from("curated_candidates")
        .select("id,status")
        .eq("raw_place_id", row.id)
        .eq("raw_hash", row.raw_hash)
        .maybeSingle();
      if (existingCandidate.data?.id) {
        skipped += 1;
        continue;
      }

      const normName = normalizeName(row.name);
      if (!normName || GENERIC_BLOCKLIST.has(normName)) {
        skipped += 1;
        continue;
      }

      const category = mapCategory(row.types ?? []);
      const rating = Number(row.rating ?? 0);
      const reviews = Number(row.user_ratings_total ?? 0);
      const lowDensityFallback = districtPublished < 40;

      if (["food", "cafe", "lodging"].includes(category)) {
        const pass = lowDensityFallback
          ? (rating >= 4.0 && reviews >= 20)
          : (rating >= 4.2 && reviews >= 50);
        if (!pass) {
          skipped += 1;
          continue;
        }
      }

      let isMerged = false;
      for (const kv of candidateMap.values()) {
        const d = haversineMeters(row.lat, row.lng, kv.lat, kv.lng);
        if (d < 100 && jaccardWords(row.name, kv.name) >= 0.85) {
          isMerged = true;
          break;
        }
      }
      if (isMerged) {
        merged += 1;
        continue;
      }

      const ai = await maybeOpenAiHap(row, district.district_name);
      const hap = ai ?? buildTemplateHap(row, district.district_name);

      const created = await service.from("curated_candidates").insert({
        raw_place_id: row.id,
        province_id: row.province_id,
        district_id: row.district_id,
        name: row.name,
        category: hap.category,
        tags: hap.tags,
        short_desc: hap.short_desc,
        history_tip: hap.history_tip,
        eat_tip: hap.eat_tip,
        pro_tip: hap.pro_tip,
        score_boost: hap.score_boost,
        status: "draft",
        raw_hash: row.raw_hash,
      }).select("id").single();

      if (created.error || !created.data?.id) {
        skipped += 1;
        continue;
      }

      drafts += 1;
      candidateMap.set(created.data.id, { name: row.name, lat: row.lat, lng: row.lng });

      if (autoApproveSafe) {
        const safeNature = ["nature", "historical", "viewpoint", "museum", "tour"].includes(hap.category) && rating >= 4.2 && reviews >= 50;
        const safeFood = ["food", "cafe"].includes(hap.category) && rating >= 4.5 && reviews >= 150;
        if (safeNature || safeFood) safeApproveIds.push(created.data.id);
      }

      await service
        .from("raw_places")
        .update({ normalized_at: new Date().toISOString() })
        .eq("id", row.id);
    }

    if (safeApproveIds.length > 0) {
      const approvedRes = await service.rpc("approve_curated_candidates", {
        p_candidate_ids: safeApproveIds,
        p_action: "approve",
      });
      if (!approvedRes.error) {
        approved = ((approvedRes.data as Array<Record<string, unknown>> | null) ?? []).filter((x) => String(x.status) === "approved").length;
      }
    }

    return jsonResponse({
      ok: true,
      district_id: district.district_id,
      drafts,
      approved,
      merged,
      skipped,
      auto_approve_safe: autoApproveSafe,
      low_density_fallback: districtPublished < 40,
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 500);
  }
});
