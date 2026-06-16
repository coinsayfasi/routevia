import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

const FREE_DAILY_LIMIT = 3;
const GEMINI_MODEL = "gemini-flash-latest";

interface ChatMessage {
  role: "user" | "model";
  text: string;
}

interface RequestBody {
  message: string;
  province_slug: string;
  province_name: string;
  history?: ChatMessage[];
}

async function isUserPro(service: ReturnType<typeof getServiceClient>, userId: string): Promise<boolean> {
  try {
    const { data } = await service
      .from("user_entitlements")
      .select("expires_at")
      .eq("user_id", userId)
      .eq("entitlement_key", "routevia_pro")
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();
    return !!data;
  } catch {
    return false;
  }
}

async function getTodayCount(service: ReturnType<typeof getServiceClient>, userId: string): Promise<number> {
  try {
    const dayStart = new Date();
    dayStart.setUTCHours(0, 0, 0, 0);
    const { count } = await service
      .from("ai_chat_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", dayStart.toISOString());
    return count ?? 0;
  } catch {
    // Tablo henüz oluşturulmamışsa limiti pas geç
    return 0;
  }
}

async function logChat(service: ReturnType<typeof getServiceClient>, userId: string, provinceSlug: string): Promise<void> {
  try {
    await service.from("ai_chat_logs").insert({ user_id: userId, province_slug: provinceSlug });
  } catch {
    // Tablo yoksa sessizce geç — oran limiti olmadan çalışmaya devam et
  }
}

async function getProvincePlaces(service: ReturnType<typeof getServiceClient>, provinceSlug: string): Promise<string> {
  try {
    const { data: prov } = await service
      .from("provinces")
      .select("id")
      .eq("slug", provinceSlug)
      .maybeSingle();
    if (!prov?.id) return "";

    const { data } = await service
      .from("places_clean")
      .select("name, category")
      .eq("province_id", prov.id)
      .order("popularity_score", { ascending: false })
      .limit(20);
    if (!data || data.length === 0) return "";
    return data.map((p: { name: string; category: string }) => `- ${p.name} (${p.category})`).join("\n");
  } catch {
    return "";
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    const service = getServiceClient();

    const body: RequestBody = await req.json();
    const { message, province_slug, province_name, history = [] } = body;

    if (!message?.trim()) return jsonResponse({ error: "message required" }, 400);
    if (!province_name) return jsonResponse({ error: "province_name required" }, 400);

    // ── Premium / rate limit kontrolü ────────────────────────────────────────
    const pro = await isUserPro(service, user.id);
    let remaining = 999;

    if (!pro) {
      const todayCount = await getTodayCount(service, user.id);
      remaining = Math.max(0, FREE_DAILY_LIMIT - todayCount);
      if (remaining === 0) {
        return jsonResponse({
          error: "daily_limit_reached",
          message: `Günlük ${FREE_DAILY_LIMIT} ücretsiz soru hakkın doldu. Sınırsız sohbet için Routevia Pro'ya geç.`,
          remaining: 0,
          pro_required: true,
        }, 429);
      }
    }

    // ── Gemini API ────────────────────────────────────────────────────────────
    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) return jsonResponse({ error: "AI servisi yapılandırılmamış." }, 500);

    const places = await getProvincePlaces(service, province_slug);

    const systemInstruction = `Sen Routevia'nın seyahat asistanısın. Adın Rota AI. Kullanıcı şu an ${province_name} ilini keşfediyor.

${places ? `${province_name} ilindeki öne çıkan yerler:\n${places}\n` : ""}
Görevin:
- ${province_name} hakkında kısa, samimi ve yardımcı cevaplar ver
- Sadece seyahat, gezi, yeme-içme, konaklama, aktivite konularında yanıtla
- Cevapların maksimum 3-4 cümle olsun
- Türkçe konuş (kullanıcı İngilizce yazarsa İngilizce yanıtla)
- Routevia uygulamasının "Plan Yap" özelliğini uygun yerlerde öner
- Bilmediğin bir şeyi uydurma`;

    const contents = [
      ...history.map((m) => ({
        role: m.role,
        parts: [{ text: m.text }],
      })),
      { role: "user", parts: [{ text: message }] },
    ];

    const geminiRes = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${geminiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          system_instruction: { parts: [{ text: systemInstruction }] },
          contents,
          generationConfig: { temperature: 0.7, maxOutputTokens: 1024, topP: 0.9 },
          safetySettings: [
            { category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
            { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
          ],
        }),
      },
    );

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      console.error("Gemini error:", geminiRes.status, errText);
      return jsonResponse({ error: "AI servisi şu an yanıt veremiyor, tekrar dene." }, 502);
    }

    const geminiData = await geminiRes.json();
    const reply = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    if (!reply) return jsonResponse({ error: "AI boş yanıt döndü, tekrar dene." }, 502);

    // ── Kullanımı logla (hata olursa sessizce geç) ────────────────────────────
    await logChat(service, user.id, province_slug ?? "");

    const newRemaining = pro ? 999 : Math.max(0, remaining - 1);

    return jsonResponse({ reply, remaining: newRemaining, is_pro: pro });
  } catch (err) {
    console.error("travel_chat error:", err);
    return errorResponse(err);
  }
});
