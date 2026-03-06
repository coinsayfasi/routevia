#!/usr/bin/env node
import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const limitArg = process.argv.find((a) => a.startsWith('--limit='));
const limit = limitArg ? Number(limitArg.split('=')[1]) : 2000;

const supabase = createClient(url, key, { auth: { persistSession: false } });

const { data, error } = await supabase.rpc('ensure_place_media_placeholders_clean', {
  p_limit: Number.isFinite(limit) ? limit : 2000,
});

if (error) {
  console.error('ensure_place_media_placeholders_clean failed:', error.message);
  process.exit(1);
}

console.log(JSON.stringify(data?.[0] ?? data, null, 2));
