/**
 * weekly_push_digest — Sends personalized "Bu Hafta Git" push notifications.
 *
 * Intended to be called by pg_cron every Monday at 09:00 UTC.
 * Also callable via POST from admin dashboard for manual triggers.
 *
 * For each user who has:
 *   - A push token registered
 *   - A preferred province set in their profile
 *   - Not received a digest in the last 6 days
 *
 * Sends a push notification with a seasonal recommendation for their province.
 */
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";
import { sendFirebasePush } from "../_shared/firebase.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

const DIGEST_COOLDOWN_HOURS = 144; // 6 days

// Curated weekly messages per season
function getWeeklyMessage(provinceName: string, month: number): { title: string; body: string } {
  if (month >= 3 && month <= 5) {
    return {
      title: `${provinceName} bu hafta seni bekliyor 🌸`,
      body: "İlkbaharın en güzel anları için en iyi rotalar seçildi. Çıkmak için mükemmel hafta!",
    };
  } else if (month >= 6 && month <= 8) {
    return {
      title: `${provinceName}'da bu hafta keşfedilecek 5 yer ☀️`,
      body: "Yaz sezonu rotalarınız hazır. Şimdi çıkın, rüzgarı hissedin!",
    };
  } else if (month >= 9 && month <= 11) {
    return {
      title: `${provinceName} sonbahar rotaları hazır 🍂`,
      body: "Bu hafta doğa ve tarihin en güzel iç içe geçtiği rotalar sizi bekliyor.",
    };
  } else {
    return {
      title: `${provinceName}'da kış keşfi 🏔️`,
      body: "Soğuk hava bahane değil! Bu hafta için en iyi iç mekan ve doğa rotaları hazır.",
    };
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    // Allow admin or service-role (for cron calls)
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrService(authHeader);

    const service = getServiceClient();
    const now = new Date();
    const month = now.getMonth() + 1; // 1-12
    const cutoff = new Date(now.getTime() - DIGEST_COOLDOWN_HOURS * 60 * 60 * 1000).toISOString();

    // Get users with push tokens who haven't been notified recently
    const { data: candidates, error: candidatesError } = await service
      .from("user_push_tokens")
      .select("id, user_id, token, platform")
      .eq("enabled", true)
      .or(`last_digest_at.is.null,last_digest_at.lt.${cutoff}`)
      .limit(500);

    if (candidatesError) return jsonResponse({ error: candidatesError.message }, 500);
    if (!candidates || candidates.length === 0) {
      return jsonResponse({ ok: true, sent: 0, reason: "no_eligible_users" });
    }

    // Get preferred provinces for these users
    const userIds = [...new Set(candidates.map((c: { user_id: string }) => c.user_id))];
    const { data: profiles, error: profilesError } = await service
      .from("profiles")
      .select("id, preferred_province_slug, preferred_province_name, allow_notifications")
      .in("id", userIds);

    if (profilesError) {
      return jsonResponse({ error: profilesError.message }, 500);
    }

    // Build user → province map
    const provinceByUser = new Map<string, { slug: string; name: string }>();
    for (const profile of (profiles ?? [])) {
      if (profile.allow_notifications === false) continue;
      if (profile.preferred_province_slug && profile.preferred_province_name) {
        provinceByUser.set(profile.id, {
          slug: profile.preferred_province_slug,
          name: profile.preferred_province_name,
        });
      }
    }

    let sent = 0;
    let skipped = 0;
    const tokenIdsToUpdate: string[] = [];

    // Check Firebase secrets
    if (!Deno.env.get("FIREBASE_PROJECT_ID")) {
      return jsonResponse({ ok: false, skipped: "firebase_secrets_missing" });
    }

    for (const candidate of candidates) {
      const province = provinceByUser.get(candidate.user_id);
      if (!province) {
        skipped++;
        continue;
      }
      const { title, body } = getWeeklyMessage(province.name, month);
      try {
        await sendFirebasePush({
          token: candidate.token,
          title,
          body,
          data: {
            type: "weekly_digest",
            province_slug: province.slug,
            screen: "home",
          },
        });
        sent++;
        tokenIdsToUpdate.push(candidate.id);
      } catch (_) {
        skipped++;
      }
    }

    // Update last_digest_at for successful sends
    if (tokenIdsToUpdate.length > 0) {
      await service
        .from("user_push_tokens")
        .update({ last_digest_at: now.toISOString() })
        .in("id", tokenIdsToUpdate);
    }

    return jsonResponse({ ok: true, sent, skipped });
  } catch (error) {
    return errorResponse(error);
  }
});
