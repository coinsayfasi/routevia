const encoder = new TextEncoder();

function base64UrlEncode(input: Uint8Array | string) {
  const bytes = typeof input === "string" ? encoder.encode(input) : input;
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function pemToArrayBuffer(pem: string) {
  const normalized = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const binary = atob(normalized);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

type FirebaseCreds = { projectId: string; clientEmail: string; privateKey: string };

function getFirebaseCreds(): FirebaseCreds | null {
  // Prefer individual vars; fall back to parsing FIREBASE_SERVICE_ACCOUNT_JSON blob.
  const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
  const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const privateKey = (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "").replace(/\\n/g, "\n");

  if (projectId && clientEmail && privateKey) {
    return { projectId, clientEmail, privateKey };
  }

  const jsonBlob = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (jsonBlob) {
    try {
      const sa = JSON.parse(jsonBlob) as Record<string, string>;
      if (sa.project_id && sa.client_email && sa.private_key) {
        return {
          projectId: sa.project_id,
          clientEmail: sa.client_email,
          privateKey: sa.private_key.replace(/\\n/g, "\n"),
        };
      }
    } catch (_) {}
  }

  return null;
}

async function mintAccessToken(creds: FirebaseCreds): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: creds.clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const unsigned = `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(JSON.stringify(payload))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(creds.privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, encoder.encode(unsigned));
  const assertion = `${unsigned}.${base64UrlEncode(new Uint8Array(signature))}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!res.ok) throw new Error(`Firebase OAuth failed: ${await res.text()}`);
  const json = await res.json() as { access_token?: string };
  if (!json.access_token) throw new Error("Firebase OAuth missing access_token");
  return json.access_token;
}

// Shared session-level token cache (lives for the duration of one function invocation).
let _cachedToken: string | null = null;
let _cachedProjectId: string | null = null;

async function getAccessToken(creds: FirebaseCreds): Promise<string> {
  if (!_cachedToken) _cachedToken = await mintAccessToken(creds);
  _cachedProjectId = creds.projectId;
  return _cachedToken;
}

export async function sendFirebasePush(input: {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  const creds = getFirebaseCreds();
  if (!creds) throw new Error("firebase_secrets_missing");

  const accessToken = await getAccessToken(creds);
  return _sendWithToken(accessToken, _cachedProjectId!, input);
}

async function _sendWithToken(
  accessToken: string,
  projectId: string,
  input: { token: string; title: string; body: string; data?: Record<string, string> },
) {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    signal: AbortSignal.timeout(10_000),
    body: JSON.stringify({
      message: {
        token: input.token,
        notification: { title: input.title, body: input.body },
        data: input.data ?? {},
        android: {
          priority: "high",
          notification: { channel_id: "routevia_updates", sound: "default" },
        },
        apns: {
          headers: { "apns-priority": "10" },
          payload: { aps: { sound: "default" } },
        },
      },
    }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`FCM send failed: ${text}`);
  }
  return await res.json();
}

// Batch: mints the OAuth token once, then sends all messages in parallel.
export async function sendFirebasePushBatch(messages: Array<{
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}>): Promise<{ sent: number; failed: number }> {
  if (messages.length === 0) return { sent: 0, failed: 0 };

  const creds = getFirebaseCreds();
  if (!creds) throw new Error("firebase_secrets_missing");

  const accessToken = await getAccessToken(creds);
  const projectId = creds.projectId;

  const results = await Promise.allSettled(
    messages.map((msg) => _sendWithToken(accessToken, projectId, msg)),
  );

  let sent = 0;
  let failed = 0;
  for (const r of results) {
    if (r.status === "fulfilled") sent++;
    else failed++;
  }
  return { sent, failed };
}

export { getFirebaseCreds };
