import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { getServiceClient, requireAdminOrService } from "../_shared/client.ts";
import { sendFirebasePush } from "../_shared/firebase.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/http.ts";

type ReminderRow = {
  id: string;
  user_id: string;
  event_id: string;
  last_notified_at: string | null;
};

type EventRow = {
  id: string;
  province_id: string;
  province_name: string;
  name: string;
  month_start: number;
  month_end: number;
  is_active: boolean;
};

type TokenRow = {
  id: string;
  user_id: string;
  token: string;
};

function isEventInMonth(event: EventRow, month: number) {
  return month >= event.month_start && month <= event.month_end;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? undefined;
    await requireAdminOrService(authHeader);

    if (!Deno.env.get("FIREBASE_PROJECT_ID") || !Deno.env.get("FIREBASE_CLIENT_EMAIL") || !Deno.env.get("FIREBASE_PRIVATE_KEY")) {
      return jsonResponse({ ok: false, skipped: "firebase_secrets_missing" });
    }

    const service = getServiceClient();
    const now = new Date();
    const month = now.getUTCMonth() + 1;
    const monthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)).toISOString();

    const { data: reminders, error: remindersError } = await service
      .from("user_event_reminders")
      .select("id,user_id,event_id,last_notified_at")
      .or(`last_notified_at.is.null,last_notified_at.lt.${monthStart}`)
      .limit(5000);

    if (remindersError) return jsonResponse({ error: remindersError.message }, 500);
    if (!reminders || reminders.length === 0) {
      return jsonResponse({ ok: true, sent: 0, reason: "no_pending_reminders" });
    }

    const reminderRows = reminders as ReminderRow[];
    const eventIds = [...new Set(reminderRows.map((row) => row.event_id))];
    const userIds = [...new Set(reminderRows.map((row) => row.user_id))];

    const [
      { data: events, error: eventsError },
      { data: tokens, error: tokensError },
      { data: profiles, error: profilesError },
    ] = await Promise.all([
      service
        .from("events")
        .select("id,province_id,province_name,name,month_start,month_end,is_active")
        .in("id", eventIds)
        .eq("is_active", true),
      service
        .from("user_push_tokens")
        .select("id,user_id,token")
        .in("user_id", userIds)
        .eq("enabled", true),
      service
        .from("profiles")
        .select("id,allow_notifications")
        .in("id", userIds),
    ]);

    if (eventsError) return jsonResponse({ error: eventsError.message }, 500);
    if (tokensError) return jsonResponse({ error: tokensError.message }, 500);
    if (profilesError) return jsonResponse({ error: profilesError.message }, 500);

    const notificationsAllowed = new Set(
      (profiles ?? [])
        .filter((profile) => profile.allow_notifications !== false)
        .map((profile) => String(profile.id)),
    );

    const provinceIds = [...new Set(((events ?? []) as EventRow[]).map((row) => row.province_id))];
    const { data: provinces, error: provincesError } = await service
      .from("provinces")
      .select("id,slug")
      .in("id", provinceIds);

    if (provincesError) return jsonResponse({ error: provincesError.message }, 500);

    const eventById = new Map<string, EventRow>();
    for (const event of (events ?? []) as EventRow[]) {
      if (isEventInMonth(event, month)) {
        eventById.set(event.id, event);
      }
    }
    if (eventById.size == 0) {
      return jsonResponse({ ok: true, sent: 0, reason: "no_events_for_current_month" });
    }

    const tokensByUser = new Map<string, TokenRow[]>();
    for (const token of (tokens ?? []) as TokenRow[]) {
      if (!notificationsAllowed.has(token.user_id)) continue;
      const bucket = tokensByUser.get(token.user_id) ?? [];
      bucket.push(token);
      tokensByUser.set(token.user_id, bucket);
    }

    const provinceSlugById = new Map<string, string>();
    for (const province of (provinces ?? []) as Array<{ id: string; slug: string }>) {
      provinceSlugById.set(province.id, province.slug);
    }

    let sent = 0;
    let skipped = 0;
    const reminderIdsToUpdate = new Set<string>();

    for (const reminder of reminderRows) {
      const event = eventById.get(reminder.event_id);
      if (!event) {
        skipped += 1;
        continue;
      }
      const userTokens = tokensByUser.get(reminder.user_id) ?? [];
      if (userTokens.length === 0) {
        skipped += 1;
        continue;
      }

      const provinceSlug = provinceSlugById.get(event.province_id) ?? "";
      const title = `${event.name} yaklaşıyor`;
      const body = `${event.province_name} için seçtiğin etkinlik bu ay başlıyor. Planını Routevia'da oluştur.`;

      let delivered = false;
      for (const token of userTokens) {
        try {
          await sendFirebasePush({
            token: token.token,
            title,
            body,
            data: {
              type: "event_reminder",
              event_id: event.id,
              province_slug: provinceSlug,
              screen: "local-hub",
            },
          });
          sent += 1;
          delivered = true;
        } catch (_) {
          skipped += 1;
        }
      }
      if (delivered) {
        reminderIdsToUpdate.add(reminder.id);
      }
    }

    if (reminderIdsToUpdate.size > 0) {
      await service
        .from("user_event_reminders")
        .update({ last_notified_at: now.toISOString() })
        .in("id", [...reminderIdsToUpdate]);
    }

    return jsonResponse({
      ok: true,
      sent,
      updated_reminders: reminderIdsToUpdate.size,
      skipped,
    });
  } catch (error) {
    return errorResponse(error);
  }
});
