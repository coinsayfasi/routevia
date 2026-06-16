import { createClient } from "https://esm.sh/@supabase/supabase-js@2.58.0";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

if (!supabaseUrl || !anonKey || !serviceRoleKey) {
  throw new Error("Missing SUPABASE_URL/SUPABASE_ANON_KEY/SUPABASE_SERVICE_ROLE_KEY.");
}

export function getUserClient(authHeader?: string) {
  return createClient(supabaseUrl, anonKey, {
    global: {
      headers: authHeader ? { Authorization: authHeader } : {},
    },
  });
}

export function getServiceClient() {
  return createClient(supabaseUrl, serviceRoleKey);
}

export async function requireUser(authHeader?: string) {
  if (!authHeader) {
    throw new Error("Missing Authorization header");
  }

  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  const serviceClient = getServiceClient();
  const { data, error } = await serviceClient.auth.getUser(token);

  if (error || !data.user) {
    throw new Error("Unauthorized");
  }

  return data.user;
}

export async function requireAdmin(userId: string) {
  const serviceClient = getServiceClient();
  const { data, error } = await serviceClient
    .from("profiles")
    .select("role")
    .eq("id", userId)
    .maybeSingle();

  if (error || !data || data.role !== "admin") {
    throw new Error("Admin required");
  }
}

export async function requireAdminOrService(authHeader?: string) {
  const token = authHeader?.replace(/^Bearer\s+/i, "").trim() ?? "";
  if (token && token === serviceRoleKey) {
    return { id: "service_role" };
  }

  const user = await requireUser(authHeader);
  await requireAdmin(user.id);
  return user;
}

export async function requireAdminOrWorker(authHeader: string | undefined, workerSecretHeader: string | null) {
  const expected = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (expected && workerSecretHeader && workerSecretHeader === expected) {
    return { id: "worker" };
  }
  return requireAdminOrService(authHeader);
}
