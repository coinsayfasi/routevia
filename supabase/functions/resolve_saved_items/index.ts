import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";

function norm(input: string): string {
  return input
    .toLowerCase()
    .replaceAll("ş", "s")
    .replaceAll("ı", "i")
    .replaceAll("ç", "c")
    .replaceAll("ğ", "g")
    .replaceAll("ö", "o")
    .replaceAll("ü", "u")
    .replaceAll(/[^a-z0-9\s]/g, " ")
    .replaceAll(/\s+/g, " ")
    .trim();
}

function extractQuery(raw: string): string {
  if (raw.startsWith("http://") || raw.startsWith("https://")) {
    try {
      const u = new URL(raw);
      const candidates = [u.searchParams.get("q"), u.searchParams.get("query"), ...u.pathname.split("/")]
        .filter(Boolean)
        .map((x) => decodeURIComponent(String(x)));
      return norm(candidates.join(" "));
    } catch {
      return norm(raw);
    }
  }
  return norm(raw);
}

function jaccard(a: string, b: string): number {
  const sa = new Set(a.split(" ").filter(Boolean));
  const sb = new Set(b.split(" ").filter(Boolean));
  const inter = [...sa].filter((x) => sb.has(x)).length;
  const uni = new Set([...sa, ...sb]).size;
  if (!uni) return 0;
  return inter / uni;
}

function proximityBonus(lat: number | null, lng: number | null, pLat: number | null, pLng: number | null): number {
  if (lat == null || lng == null || pLat == null || pLng == null) return 0;
  const d = Math.abs(lat - pLat) + Math.abs(lng - pLng);
  return Math.max(0, 0.2 - d);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireUser(authHeader);

    const body = (await req.json()) as {
      province_id: string;
      items: { text_or_url: string }[];
      lat?: number;
      lng?: number;
    };

    if (!body.province_id || !body.items?.length) {
      return jsonResponse({ error: "province_id and items are required" }, 400);
    }

    const service = getServiceClient();
    const { data: province } = await service
      .from("provinces")
      .select("name")
      .eq("id", body.province_id)
      .maybeSingle();

    const provinceName = String(province?.name ?? "").trim();
    if (!provinceName) {
      return jsonResponse({ error: "province not found" }, 404);
    }

    const { data: rows, error } = await service
      .from("pois")
      .select("id,name,category,city,district,tags,lat,lng,source")
      .eq("provenance_verified", true)
      .in("source", ["osm", "wikidata", "user", "licensed"])
      .ilike("city", provinceName)
      .limit(2000);

    if (error) return jsonResponse({ error: error.message }, 500);

    const places = (rows as Record<string, unknown>[] | null) ?? [];

    const resolved = body.items.map((item) => {
      const query = extractQuery(item.text_or_url);
      const results = places
        .map((p) => {
          const nameNorm = norm(String(p.name));
          const nameSimilarity = jaccard(query, nameNorm);
          const includesBoost = nameNorm.includes(query) || query.includes(nameNorm) ? 0.2 : 0;
          const hints = ["food", "cafe", "beach", "museum", "nature", "sunset", "market", "historical"];
          const tags = Array.isArray(p.tags) ? (p.tags as unknown[]).map((t) => String(t)) : [];
          const hintBoost = hints.filter((h) => query.includes(h) && (tags.includes(h) || String(p.category) === h)).length * 0.05;
          const prox = proximityBonus(
            body.lat ?? null,
            body.lng ?? null,
            (p.lat as number | null) ?? null,
            (p.lng as number | null) ?? null
          );
          const confidence = Math.max(0, Math.min(1, nameSimilarity * 0.65 + includesBoost + hintBoost + prox));

          return {
            place_id: p.id,
            name: p.name,
            category: p.category,
            short_summary: `${String(p.district ?? p.city ?? "")}`.trim(),
            confidence,
          };
        })
        .sort((a, b) => b.confidence - a.confidence)
        .slice(0, 3);

      return {
        item: item.text_or_url,
        query,
        candidates: results,
        top_confidence: results[0]?.confidence ?? 0,
        needs_confirmation: (results[0]?.confidence ?? 0) < 0.75,
      };
    });

    return jsonResponse({
      results: resolved,
      llm_intent_enabled: (Deno.env.get("ENABLE_LLM_INTENT") ?? "false") === "true",
      mode: "deterministic",
    });
  } catch (error) {
    return errorResponse(error);
  }
});
