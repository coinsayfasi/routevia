import { z } from "zod";

export const moderationDecisionSchema = z.object({
  submissionType: z.enum([
    "place_submission",
    "story_submission",
    "photo_submission",
  ]),
  submissionId: z.string().uuid(),
  decision: z.enum(["pending", "approved", "rejected", "needs_edit"]),
  adminNote: z.string().max(2000).optional(),
  rejectionReason: z.string().max(2000).optional(),
  publish: z.boolean().default(true),
  setCover: z.boolean().default(false),
});

export type ModerationDecisionInput = z.infer<typeof moderationDecisionSchema>;
