"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { moderationDecisionSchema } from "@/lib/zod/moderation";
import { createSupabaseAdminClient } from "@/lib/supabase/server";

export async function moderateSubmission(input: unknown) {
  const { user } = await requireAdmin();
  const parsed = moderationDecisionSchema.parse(input);
  const supabase = await createSupabaseAdminClient();

  const { error } = await supabase.rpc("admin_moderate_submission", {
    p_submission_type: parsed.submissionType,
    p_submission_id: parsed.submissionId,
    p_decision: parsed.decision,
    p_admin_note: parsed.adminNote?.trim() || null,
    p_rejection_reason: parsed.rejectionReason?.trim() || null,
    p_publish: parsed.publish,
    p_set_cover: parsed.setCover,
    p_actor_user_id: user.id === "local-admin-bypass" ? null : user.id,
  });

  if (error) {
    throw error;
  }

  revalidatePath("/");
  revalidatePath("/moderation");
  revalidatePath(`/moderation/${parsed.submissionType}/${parsed.submissionId}`);
}
