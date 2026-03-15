export type ModerationStatus = "pending" | "approved" | "rejected" | "needs_edit";

export type SubmissionType =
  | "place_submission"
  | "story_submission"
  | "photo_submission";

export type ModerationQueueRow = {
  id: string;
  submission_type: SubmissionType;
  submission_id: string;
  status: ModerationStatus;
  user_id: string;
  place_id: string | null;
  city_id: string | null;
  place_name: string | null;
  city_name: string | null;
  submitter_name: string | null;
  searchable_title: string | null;
  searchable_excerpt: string | null;
  bucket: string | null;
  object_path: string | null;
  admin_note: string | null;
  rejection_reason: string | null;
  queue_rank: number;
  submitted_at: string;
  reviewed_at: string | null;
  reviewed_by: string | null;
};

export type DashboardStats = {
  pendingPlaces: number;
  pendingStories: number;
  pendingPhotos: number;
  approvedToday: number;
  rejectedToday: number;
};
