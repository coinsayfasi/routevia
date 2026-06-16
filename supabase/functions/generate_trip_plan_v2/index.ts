import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

const GEMINI_MODEL = "gemini-2.0-flash";

interface StopInput {
  name: string;
  category: string;
  city?: string;
  district?: string;
}

interface DayInput {
  day: number;
  stops: StopInput[];
}

interface RequestBody {
  province_name: string;
  days: DayInput[];
  transport_mode?: string;
  pace?: string;
  lang?: "tr" | "en";
}

interface EnrichedStop {
  name: string;
  ai_tip: string;
}

interface EnrichedDay {
  day: number;
  theme: string;
  stops: EnrichedStop[];
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireUser(authHeader);

    const body: RequestBody = await req.json();
    const { province_name, days, transport_mode = "walk", pace = "normal", lang = "tr" } = body;

    if (!province_name || !days?.length) {
      return jsonResponse({ error: "province_name ve days zorunlu" }, 400);
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) return jsonResponse({ error: "AI servisi yapılandırılmamış." }, 500);

    const isTr = lang === "tr";

    const stopsText = days.map((d) =>
      `Gün ${d.day}: ${d.stops.map((s) => `${s.name} (${s.category})`).join(", ")}`
    ).join("\n");

    const transportLabel = transport_mode === "car"
      ? (isTr ? "araçla" : "by car")
      : transport_mode === "bike"
      ? (isTr ? "bisikletle" : "by bike")
      : (isTr ? "yürüyerek/toplu taşıma" : "walking/transit");

    const prompt = isTr
      ? `Sen Routevia'nın seyahat asistanısın. Kullanıcı ${province_name} için ${days.length} günlük bir gezi planı oluşturdu.
Ulaşım: ${transportLabel}. Tempo: ${pace === "slow" ? "yavaş, rahat" : pace === "fast" ? "hızlı" : "normal"}.

Gezi planı:
${stopsText}

Her gün için:
1. Kısa bir gün teması (max 8 kelime)
2. Her durak için pratik, samimi bir ipucu (1-2 cümle, uydurma bilgi verme)

JSON formatında yanıt ver:
{
  "days": [
    {
      "day": 1,
      "theme": "...",
      "stops": [
        {"name": "...", "ai_tip": "..."}
      ]
    }
  ],
  "overall_summary": "Tüm gezi için 2-3 cümlelik ilham verici bir özet"
}`
      : `You are Routevia's travel assistant. The user created a ${days.length}-day trip plan for ${province_name}.
Transport: ${transportLabel}. Pace: ${pace}.

Trip plan:
${stopsText}

For each day provide:
1. A short day theme (max 8 words)
2. A practical, genuine tip for each stop (1-2 sentences, no made-up facts)

Respond in JSON:
{
  "days": [
    {
      "day": 1,
      "theme": "...",
      "stops": [
        {"name": "...", "ai_tip": "..."}
      ]
    }
  ],
  "overall_summary": "2-3 sentence inspiring summary of the whole trip"
}`;

    const geminiRes = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${geminiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.65,
            maxOutputTokens: 2048,
            responseMimeType: "application/json",
          },
        }),
      },
    );

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      console.error("Gemini error:", geminiRes.status, errText);
      return jsonResponse({ error: "AI servisi yanıt vermedi, tekrar dene." }, 502);
    }

    const geminiData = await geminiRes.json();
    const rawText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    if (!rawText) return jsonResponse({ error: "AI boş yanıt döndü." }, 502);

    let enriched: { days: EnrichedDay[]; overall_summary: string };
    try {
      enriched = JSON.parse(rawText);
    } catch {
      return jsonResponse({ error: "AI yanıtı parse edilemedi." }, 502);
    }

    return jsonResponse({ ok: true, ...enriched });
  } catch (err) {
    console.error("generate_trip_plan_v2 error:", err);
    return errorResponse(err);
  }
});
