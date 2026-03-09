export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

export function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });
}

/**
 * Maps a caught error to the correct HTTP status code and returns a jsonResponse.
 * Use in catch blocks instead of hardcoding 401.
 */
export function errorResponse(error: unknown): Response {
  const message = error instanceof Error ? error.message : String(error);
  const lower = message.toLowerCase();

  if (
    lower === "unauthorized" ||
    lower === "missing authorization header" ||
    lower.includes("jwt") ||
    lower.includes("invalid token")
  ) {
    return jsonResponse({ error: message }, 401);
  }

  if (lower === "admin required" || lower.includes("forbidden")) {
    return jsonResponse({ error: message }, 403);
  }

  if (lower === "place not found" || lower.includes("not found")) {
    return jsonResponse({ error: message }, 404);
  }

  if (lower.includes("rate limit") || lower.includes("limit exceeded")) {
    return jsonResponse({ error: message }, 429);
  }

  return jsonResponse({ error: message }, 400);
}
