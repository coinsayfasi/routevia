import { cache } from "react";
import { createSupabaseAdminClient } from "@/lib/supabase/server";
import type { DashboardStats, ModerationQueueRow, ModerationStatus, SubmissionType } from "@/lib/types/moderation";

export const getDashboardStats = cache(async (): Promise<DashboardStats> => {
  const supabase = await createSupabaseAdminClient();
  const today = new Date().toISOString().slice(0, 10);

  const [pendingPlaces, pendingStories, pendingPhotos, approvedToday, rejectedToday] =
    await Promise.all([
      supabase
        .from("moderation_queue")
        .select("id", { count: "exact", head: true })
        .eq("submission_type", "place_submission")
        .eq("status", "pending"),
      supabase
        .from("moderation_queue")
        .select("id", { count: "exact", head: true })
        .eq("submission_type", "story_submission")
        .eq("status", "pending"),
      supabase
        .from("moderation_queue")
        .select("id", { count: "exact", head: true })
        .eq("submission_type", "photo_submission")
        .eq("status", "pending"),
      supabase
        .from("moderation_queue")
        .select("id", { count: "exact", head: true })
        .eq("status", "approved")
        .gte("reviewed_at", `${today}T00:00:00.000Z`),
      supabase
        .from("moderation_queue")
        .select("id", { count: "exact", head: true })
        .eq("status", "rejected")
        .gte("reviewed_at", `${today}T00:00:00.000Z`),
    ]);

  return {
    pendingPlaces: pendingPlaces.count ?? 0,
    pendingStories: pendingStories.count ?? 0,
    pendingPhotos: pendingPhotos.count ?? 0,
    approvedToday: approvedToday.count ?? 0,
    rejectedToday: rejectedToday.count ?? 0,
  };
});

export async function listModerationQueue(input: {
  status?: ModerationStatus | "all";
  submissionType?: SubmissionType | "all";
  search?: string;
  limit?: number;
  offset?: number;
} = {}): Promise<ModerationQueueRow[]> {
  const supabase = await createSupabaseAdminClient();
  let query = supabase
    .from("moderation_queue_overview")
    .select(
      "id,submission_type,submission_id,status,user_id,place_id,city_id,place_name,city_name,submitter_name,searchable_title,searchable_excerpt,bucket,object_path,admin_note,rejection_reason,queue_rank,submitted_at,reviewed_at,reviewed_by",
    )
    .order("queue_rank", { ascending: true })
    .order("submitted_at", { ascending: false });

  if (input.status && input.status !== "all") {
    query = query.eq("status", input.status);
  }

  if (input.submissionType && input.submissionType !== "all") {
    query = query.eq("submission_type", input.submissionType);
  }

  if (input.search && input.search.trim()) {
    query = query.or(
      `searchable_title.ilike.%${input.search.trim()}%,searchable_excerpt.ilike.%${input.search.trim()}%,place_name.ilike.%${input.search.trim()}%,submitter_name.ilike.%${input.search.trim()}%`,
    );
  }

  const limit = Math.min(Math.max(input.limit ?? 30, 1), 100);
  const offset = Math.max(input.offset ?? 0, 0);
  const { data, error } = await query.range(offset, offset + limit - 1);

  if (error) {
    throw error;
  }

  return (data ?? []) as ModerationQueueRow[];
}

export async function getModerationDetail(
  submissionType: SubmissionType,
  submissionId: string,
) {
  const supabase = await createSupabaseAdminClient();

  const queue = await supabase
    .from("moderation_queue_overview")
    .select(
      "id,submission_type,submission_id,status,user_id,place_id,city_id,place_name,city_name,submitter_name,searchable_title,searchable_excerpt,bucket,object_path,admin_note,rejection_reason,queue_rank,submitted_at,reviewed_at,reviewed_by",
    )
    .eq("submission_type", submissionType)
    .eq("submission_id", submissionId)
    .single();

  if (queue.error) {
    throw queue.error;
  }

  const table =
    submissionType === "place_submission"
      ? "user_place_submissions"
      : submissionType === "story_submission"
        ? "user_story_submissions"
        : "user_photo_submissions";

  const detail = await supabase
    .from(table)
    .select("*")
    .eq("id", submissionId)
    .single();

  if (detail.error) {
    throw detail.error;
  }

  return {
    queue: queue.data,
    detail: detail.data,
  };
}
