import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { getServiceClient, requireAdmin, requireUser } from "../_shared/client.ts";

function splitSentences(text: string): string[] {
  return text
    .replace(/\s+/g, " ")
    .split(/[.!?]\s+/)
    .map((s) => s.trim())
    .filter(Boolean);
}

function maxLen(input: string, limit: number): string {
  return input.length <= limit ? input : `${input.slice(0, limit - 1).trimEnd()}.`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    const user = await requireUser(authHeader);
    await requireAdmin(user.id);

    const { place_id, raw_notes } = (await req.json()) as { place_id?: string; raw_notes?: string };

    if (!place_id || !raw_notes) {
      return jsonResponse({ error: "place_id and raw_notes are required" }, 400);
    }

    const sentences = splitSentences(raw_notes);
    const summary = maxLen(sentences[0] ?? "Local highlight with practical tips and nearby context.", 160);
    const history = sentences.slice(0, 3).map((s) => maxLen(s, 110));
    const eat = sentences.slice(3, 6).map((s) => maxLen(s, 110));
    const tips = sentences.slice(6, 10).map((s) => maxLen(s, 110));

    const service = getServiceClient();

    await service.from("places").update({ short_summary: summary }).eq("id", place_id);

    const { error } = await service.from("place_details").upsert({
      place_id,
      history_bullets: history,
      eat_drink_bullets: eat,
      tips_bullets: tips,
    });

    if (error) {
      return jsonResponse({ error: "Failed to upsert enriched details" }, 500);
    }

    return jsonResponse({
      place_id,
      short_summary: summary,
      history_bullets: history,
      eat_drink_bullets: eat,
      tips_bullets: tips,
      mode: "deterministic",
    });
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 401);
  }
});
