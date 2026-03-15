import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";
import { createClient } from "@supabase/supabase-js";

type CookieMutation = {
  name: string;
  value: string;
  options?: Parameters<Awaited<ReturnType<typeof cookies>>["set"]>[2];
};

type StorageValue = string | null;

function createMemoryStorage() {
  const store = new Map<string, string>();

  return {
    getItem(key: string): StorageValue | Promise<StorageValue> {
      return store.get(key) ?? null;
    },
    setItem(key: string, value: string): void | Promise<void> {
      store.set(key, value);
    },
    removeItem(key: string): void | Promise<void> {
      store.delete(key);
    },
  };
}

function ensureSafeLocalStorageShim() {
  const safeStorage = createMemoryStorage();
  const current = (globalThis as { localStorage?: unknown }).localStorage;

  if (
    !current ||
    typeof current !== "object" ||
    typeof (current as { getItem?: unknown }).getItem !== "function" ||
    typeof (current as { setItem?: unknown }).setItem !== "function" ||
    typeof (current as { removeItem?: unknown }).removeItem !== "function"
  ) {
    (globalThis as { localStorage?: ReturnType<typeof createMemoryStorage> }).localStorage =
      safeStorage;
  }

  return safeStorage;
}

export async function createSupabaseServerClient() {
  const cookieStore = await cookies();
  const memoryStorage = ensureSafeLocalStorageShim();
  const supabaseUrl =
    process.env.NEXT_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL;
  const supabaseAnonKey =
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? process.env.SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase URL/anon key missing for admin app.");
  }

  return createServerClient(
    supabaseUrl,
    supabaseAnonKey,
    {
      cookieOptions: {
        secure: true,
        sameSite: "lax",
        path: "/",
      },
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: CookieMutation[]) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
        storage: memoryStorage,
      },
    },
  );
}

export async function createSupabaseAdminClient() {
  const memoryStorage = ensureSafeLocalStorageShim();
  const supabaseUrl =
    process.env.NEXT_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error("Supabase URL/service role key missing for admin app.");
  }

  return createClient(
    supabaseUrl,
    serviceRoleKey,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
        storage: memoryStorage,
      },
    },
  );
}
