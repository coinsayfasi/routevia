import { createSupabaseAdminClient } from "@/lib/supabase/server";

export interface PlaceRow {
  id: string;
  name: string;
  category: string;
  city: string | null;
  district: string | null;
  is_published: boolean | null;
  is_featured: boolean | null;
  provenance_verified: boolean | null;
  created_at: string | null;
}

export async function listPlaces(input: {
  search?: string;
  category?: string;
  published?: string;
  page?: number;
  pageSize?: number;
}): Promise<{ rows: PlaceRow[]; total: number }> {
  const supabase = await createSupabaseAdminClient();
  const pageSize = Math.min(Math.max(input.pageSize ?? 25, 1), 100);
  const page = Math.max(input.page ?? 1, 1);
  const offset = (page - 1) * pageSize;

  let query = supabase
    .from("pois")
    .select("id,name,category,city,district,is_published,is_featured,provenance_verified,created_at", {
      count: "exact",
    })
    .order("created_at", { ascending: false });

  if (input.search?.trim()) {
    query = query.ilike("name", `%${input.search.trim()}%`);
  }
  if (input.category && input.category !== "all") {
    query = query.eq("category", input.category);
  }
  if (input.published === "true") {
    query = query.eq("is_published", true);
  } else if (input.published === "false") {
    query = query.eq("is_published", false);
  }

  const { data, error, count } = await query.range(offset, offset + pageSize - 1);
  if (error) throw error;
  return { rows: (data ?? []) as PlaceRow[], total: count ?? 0 };
}

export async function listFeaturedPlaces(): Promise<PlaceRow[]> {
  const supabase = await createSupabaseAdminClient();
  const { data, error } = await supabase
    .from("pois")
    .select("id,name,category,city,district,is_published,is_featured,provenance_verified,created_at")
    .eq("is_featured", true)
    .order("name", { ascending: true });
  if (error) throw error;
  return (data ?? []) as PlaceRow[];
}
