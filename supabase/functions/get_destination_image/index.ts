import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, jsonResponse, errorResponse } from "../_shared/http.ts";

const PEXELS_API_KEY = Deno.env.get("PEXELS_API_KEY") ?? "";
const WIKI_USER_AGENT = "Routevia/1.0 (routevia@tabserve.com.tr)";

function slugify(str: string): string {
  return str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "")
    .slice(0, 80);
}

// ─── Wikimedia Commons direct URL resolver ────────────────────────────────────

/**
 * Resolves a Wikimedia Commons filename to a direct CDN thumbnail URL.
 * Uses the imageinfo API instead of Special:FilePath redirect chains.
 * e.g. "Ephesus_Celsus_Library.jpg" → "https://upload.wikimedia.org/wikipedia/commons/thumb/..."
 */
async function resolveWikimediaUrl(
  encodedFilename: string,
  width: number,
): Promise<string | null> {
  try {
    const params = new URLSearchParams({
      action: "query",
      titles: `File:${decodeURIComponent(encodedFilename)}`,
      prop: "imageinfo",
      iiprop: "url",
      iiurlwidth: String(width),
      format: "json",
      formatversion: "2",
    });
    const res = await fetch(
      `https://commons.wikimedia.org/w/api.php?${params}`,
      {
        headers: { "User-Agent": WIKI_USER_AGENT },
        signal: AbortSignal.timeout(6_000),
      },
    );
    if (!res.ok) return null;
    const data = await res.json();
    const pages = data?.query?.pages ?? [];
    const page = pages[0];
    const thumbUrl = page?.imageinfo?.[0]?.thumburl as string | undefined;
    if (thumbUrl) return thumbUrl;
    // Fallback: original URL if no thumb
    const origUrl = page?.imageinfo?.[0]?.url as string | undefined;
    return origUrl ?? null;
  } catch {
    return null;
  }
}

// ─── Wikidata P18 (most accurate — official representative image) ─────────────

interface WikiImage {
  url: string;
  credit: string;
}

/**
 * Searches Wikidata for the place and returns its P18 (image) property.
 * P18 is the curated "main image" for each Wikidata entity — highly accurate.
 * e.g. "Efes Antik Kenti" → Q48418 (Ephesus) → Great Theatre photo
 *      "Kapadokya"        → Q192150 → hot air balloon photo
 */
async function getWikidataImage(
  placeName: string,
  provinceName: string,
): Promise<WikiImage | null> {
  const queries = [
    placeName,
    `${placeName} ${provinceName}`,
    `${placeName} Turkey`,
  ];

  for (const query of queries) {
    for (const lang of ["tr", "en"]) {
      try {
        // 1. Search Wikidata for the entity
        const searchParams = new URLSearchParams({
          action: "wbsearchentities",
          search: query,
          language: lang,
          type: "item",
          format: "json",
          limit: "5",
        });
        const searchRes = await fetch(
          `https://www.wikidata.org/w/api.php?${searchParams}`,
          {
            headers: { "User-Agent": WIKI_USER_AGENT },
            signal: AbortSignal.timeout(8_000),
          },
        );
        if (!searchRes.ok) continue;
        const searchData = await searchRes.json();
        const items: Array<{ id: string; label: string; description?: string }> =
          searchData?.search ?? [];

        for (const item of items) {
          // 2. Get P18 (image) claim
          const entityParams = new URLSearchParams({
            action: "wbgetentities",
            ids: item.id,
            props: "claims",
            format: "json",
          });
          const entityRes = await fetch(
            `https://www.wikidata.org/w/api.php?${entityParams}`,
            {
              headers: { "User-Agent": WIKI_USER_AGENT },
              signal: AbortSignal.timeout(8_000),
            },
          );
          if (!entityRes.ok) continue;
          const entityData = await entityRes.json();
          const entity = entityData?.entities?.[item.id];
          const p18 = entity?.claims?.P18;
          if (!p18 || p18.length === 0) continue;

          const filename: string | undefined =
            p18[0]?.mainsnak?.datavalue?.value;
          if (!filename) continue;

          // 3. Resolve Wikimedia Commons to direct CDN thumbnail URL.
          // Special:FilePath is a redirect — resolve it to the actual upload URL
          // so mobile clients (CachedNetworkImage) get the image without redirect chains.
          const encoded = encodeURIComponent(filename.replace(/ /g, "_"));
          const directUrl = await resolveWikimediaUrl(encoded, 1200);
          if (!directUrl) continue;
          return { url: directUrl, credit: `Wikimedia Commons: ${item.label}` };
        }
      } catch {
        continue;
      }
    }
  }
  return null;
}

// ─── Wikipedia page image (fallback) ─────────────────────────────────────────

async function fetchWikiPageImage(title: string): Promise<WikiImage | null> {
  const params = new URLSearchParams({
    action: "query",
    titles: title,
    prop: "pageimages",
    pithumbsize: "1200",
    format: "json",
    formatversion: "2",
  });
  try {
    const res = await fetch(
      `https://en.wikipedia.org/w/api.php?${params}`,
      {
        headers: { "User-Agent": WIKI_USER_AGENT },
        signal: AbortSignal.timeout(6_000),
      },
    );
    if (!res.ok) return null;
    const data = await res.json();
    const page = (data?.query?.pages ?? [])[0];
    if (!page || page.missing || !page.thumbnail?.source) return null;
    return { url: page.thumbnail.source, credit: `Wikipedia: ${page.title}` };
  } catch {
    return null;
  }
}

/**
 * Turkish Wikipedia → English interlanguage link bridge.
 * Handles Turkish place names that differ from their English Wikipedia title.
 * e.g. "Efes Antik Kenti" → TR "Efes" → EN "Ephesus"
 */
async function getEnglishTitleViaTurkishWiki(query: string): Promise<string | null> {
  try {
    const searchParams = new URLSearchParams({
      action: "query",
      list: "search",
      srsearch: query,
      format: "json",
      srlimit: "3",
      formatversion: "2",
    });
    const searchRes = await fetch(
      `https://tr.wikipedia.org/w/api.php?${searchParams}`,
      {
        headers: { "User-Agent": WIKI_USER_AGENT },
        signal: AbortSignal.timeout(6_000),
      },
    );
    if (!searchRes.ok) return null;
    const searchData = await searchRes.json();
    const results: Array<{ pageid: number; title: string }> =
      searchData?.query?.search ?? [];

    for (const result of results) {
      const linkParams = new URLSearchParams({
        action: "query",
        pageids: String(result.pageid),
        prop: "langlinks",
        lllang: "en",
        format: "json",
        formatversion: "2",
      });
      const linkRes = await fetch(
        `https://tr.wikipedia.org/w/api.php?${linkParams}`,
        {
          headers: { "User-Agent": WIKI_USER_AGENT },
          signal: AbortSignal.timeout(6_000),
        },
      );
      if (!linkRes.ok) continue;
      const linkData = await linkRes.json();
      const page = (linkData?.query?.pages ?? [])[0];
      if (!page || page.missing) continue;
      const enLink = (page.langlinks ?? []).find(
        (l: { lang: string; title: string }) => l.lang === "en",
      );
      if (enLink?.title) return enLink.title;
    }
  } catch {
    // fall through
  }
  return null;
}

async function getWikipediaImage(
  placeName: string,
  provinceName: string,
  category: string,
): Promise<WikiImage | null> {
  // 1) Direct English title
  const direct = await fetchWikiPageImage(placeName);
  if (direct) return direct;

  // 2) With Turkey suffix
  const withTurkey = await fetchWikiPageImage(`${placeName}, Turkey`);
  if (withTurkey) return withTurkey;

  // 3) English Wikipedia search
  try {
    const searchParams = new URLSearchParams({
      action: "query",
      list: "search",
      srsearch: `${placeName} ${provinceName} Turkey ${category}`,
      format: "json",
      srlimit: "3",
      formatversion: "2",
    });
    const searchRes = await fetch(
      `https://en.wikipedia.org/w/api.php?${searchParams}`,
      { headers: { "User-Agent": WIKI_USER_AGENT }, signal: AbortSignal.timeout(6_000) },
    );
    if (searchRes.ok) {
      const results: Array<{ pageid: number; title: string }> =
        (await searchRes.json())?.query?.search ?? [];
      for (const result of results) {
        const imgParams = new URLSearchParams({
          action: "query",
          pageids: String(result.pageid),
          prop: "pageimages",
          pithumbsize: "1200",
          format: "json",
          formatversion: "2",
        });
        const imgRes = await fetch(`https://en.wikipedia.org/w/api.php?${imgParams}`, {
          headers: { "User-Agent": WIKI_USER_AGENT },
          signal: AbortSignal.timeout(6_000),
        });
        if (!imgRes.ok) continue;
        const page = ((await imgRes.json())?.query?.pages ?? [])[0];
        if (page?.thumbnail?.source) {
          return { url: page.thumbnail.source, credit: `Wikipedia: ${result.title}` };
        }
      }
    }
  } catch { /* fall through */ }

  // 4) Turkish Wikipedia → English interlanguage bridge
  const enTitle = await getEnglishTitleViaTurkishWiki(placeName);
  if (enTitle) {
    const wiki = await fetchWikiPageImage(enTitle);
    if (wiki) return wiki;
  }

  return null;
}

// ─── Pexels ───────────────────────────────────────────────────────────────────

async function getPexelsImage(
  searchTerm: string,
  cityName: string,
  categoryHint: string,
  isPlaceQuery: boolean,
): Promise<{ url: string; photographer: string } | null> {
  if (!PEXELS_API_KEY) return null;

  const queries = isPlaceQuery
    ? [
        `${searchTerm} ${categoryHint || "travel"} Turkey`,
        `${searchTerm} tourism`,
        `${cityName} ${categoryHint || "landmark"}`,
        `${cityName} travel`,
      ]
    : [
        `${searchTerm} city aerial`,
        `${searchTerm} cityscape`,
        `${searchTerm} city`,
        `${searchTerm} travel`,
      ];

  for (const q of queries) {
    try {
      const res = await fetch(
        `https://api.pexels.com/v1/search?query=${encodeURIComponent(q)}&per_page=15&orientation=landscape`,
        { headers: { Authorization: PEXELS_API_KEY }, signal: AbortSignal.timeout(8_000) },
      );
      if (!res.ok) continue;
      const photos = ((await res.json()).photos ?? []) as Array<{
        src: { large2x: string; large: string; original: string };
        width: number; height: number; photographer: string;
      }>;
      if (photos.length === 0) continue;
      photos.sort((a, b) => b.width / b.height - a.width / a.height);
      const p = photos[0];
      return { url: p.src.large2x ?? p.src.large ?? p.src.original, photographer: p.photographer };
    } catch { continue; }
  }
  return null;
}

// ─── Handler ──────────────────────────────────────────────────────────────────

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const body = await req.json().catch(() => ({}));
    const rawCity = ((body?.city as string) ?? "").trim().slice(0, 100);
    if (!rawCity) return jsonResponse({ error: "city is required" }, 400);

    const rawPlaceName = ((body?.place_name as string) ?? "").trim().slice(0, 120);
    const isPlaceQuery = rawPlaceName.length > 0;
    const cacheSlug = isPlaceQuery ? slugify(rawPlaceName) : slugify(rawCity);
    const categoryHint = ((body?.category as string) ?? "").trim().toLowerCase();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // 1) Cache check
    const { data: cached } = await supabase
      .from("city_images")
      .select("image_url,photographer,city_slug,source")
      .eq("city_slug", cacheSlug)
      .maybeSingle();

    // Serve cache only if it's a direct CDN URL (not a Special:FilePath redirect).
    // Old cache entries with redirect URLs are skipped so they get re-fetched and
    // replaced with direct upload.wikimedia.org/commons/thumb/... URLs.
    if (cached && !cached.image_url.includes("Special:FilePath")) {
      return jsonResponse({
        source: "cache",
        city: rawCity,
        city_slug: cacheSlug,
        image_url: cached.image_url,
        photographer: cached.photographer,
      });
    }

    let imageUrl: string | null = null;
    let photographer = "";
    let source = "pexels";

    if (isPlaceQuery) {
      // 2) Wikidata P18 — most accurate (official representative image)
      const wikidata = await getWikidataImage(rawPlaceName, rawCity);
      if (wikidata) {
        imageUrl = wikidata.url;
        photographer = wikidata.credit;
        source = "wikidata";
      }

      // 3) Wikipedia image fallback (TR→EN bridge included)
      if (!imageUrl) {
        const wiki = await getWikipediaImage(rawPlaceName, rawCity, categoryHint);
        if (wiki) {
          imageUrl = wiki.url;
          photographer = wiki.credit;
          source = "wikipedia";
        }
      }

      // Pexels fallback for place queries when Wikidata/Wikipedia have no image
      if (!imageUrl) {
        const pexels = await getPexelsImage(rawPlaceName, rawCity, categoryHint, true);
        if (pexels) {
          imageUrl = pexels.url;
          photographer = pexels.photographer;
          source = "pexels";
        }
      }
      if (!imageUrl) return jsonResponse({ error: "No image found for this place" }, 404);

    } else {
      // City/province queries: Wikipedia city image → Pexels
      const wikiCity = await fetchWikiPageImage(rawCity);
      if (wikiCity) {
        imageUrl = wikiCity.url;
        photographer = wikiCity.credit;
        source = "wikipedia";
      }
      if (!imageUrl) {
        const pexels = await getPexelsImage(rawCity, rawCity, categoryHint, false);
        if (pexels) {
          imageUrl = pexels.url;
          photographer = pexels.photographer;
          source = "pexels";
        }
      }
    }

    if (!imageUrl) return jsonResponse({ error: "No image found" }, 404);

    // 6) Cache result
    try {
      await supabase.from("city_images").upsert(
        {
          city_name: isPlaceQuery ? rawPlaceName : rawCity,
          city_slug: cacheSlug,
          image_url: imageUrl,
          photographer,
          source,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "city_slug" },
      );
    } catch (_) {}

    return jsonResponse({ source, city: rawCity, city_slug: cacheSlug, image_url: imageUrl, photographer });
  } catch (e) {
    return errorResponse(e);
  }
});
