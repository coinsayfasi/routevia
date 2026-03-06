#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const args = { input: '', dryRun: false };
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a.startsWith('--input=')) args.input = a.slice('--input='.length);
    else if (a === '--input') args.input = argv[++i] ?? '';
  }
  return args;
}

function parseCsvLine(line) {
  const out = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    const next = i + 1 < line.length ? line[i + 1] : '';
    if (ch === '"') {
      if (inQuotes && next === '"') {
        cur += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }
    if (ch === ',' && !inQuotes) {
      out.push(cur.trim());
      cur = '';
      continue;
    }
    cur += ch;
  }
  out.push(cur.trim());
  return out;
}

function escapeCsv(v) {
  const s = String(v ?? '');
  if (s.includes(',') || s.includes('"') || s.includes('\n')) return `"${s.replaceAll('"', '""')}"`;
  return s;
}

function readCsv(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8');
  const lines = raw.split(/\r?\n/).filter((l) => l.trim().length > 0);
  const headers = parseCsvLine(lines[0]).map((h) => h.trim());
  const rows = lines.slice(1).map((line) => {
    const cols = parseCsvLine(line);
    const row = {};
    headers.forEach((h, i) => {
      row[h] = cols[i] ?? '';
    });
    return row;
  });
  return { headers, rows };
}

function norm(v) {
  return String(v ?? '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

function coordKey(v) {
  const n = Number(v ?? NaN);
  if (!Number.isFinite(n)) return '';
  return n.toFixed(4); // ~11m bucket
}

function rank(row) {
  let s = 0;
  const src = String(row.source_url ?? '');
  if (src.includes('google.com/maps/place')) s += 3;
  if (String(row.tags ?? '').length > 10) s += 1;
  if (String(row.history_tip ?? '').length > 8) s += 1;
  if (String(row.eat_tip ?? '').length > 8) s += 1;
  s += Number(row.popularity_score ?? 0) / 1000;
  return s;
}

function main() {
  const args = parseArgs(process.argv);
  const repoRoot = path.resolve(process.cwd(), '..', '..');
  const input = path.resolve(process.cwd(), args.input || path.join('..', '..', 'data', 'seed', 'curated_places.csv'));
  const { headers, rows } = readCsv(input);

  const grouped = new Map();
  for (const r of rows) {
    const key = [
      String(r.province_slug ?? ''),
      String(r.district_slug ?? ''),
      norm(r.name),
      coordKey(r.lat),
      coordKey(r.lng),
    ].join('|');
    if (!grouped.has(key)) grouped.set(key, []);
    grouped.get(key).push(r);
  }

  const keep = [];
  let removed = 0;
  for (const arr of grouped.values()) {
    if (arr.length === 1) {
      keep.push(arr[0]);
      continue;
    }
    arr.sort((a, b) => rank(b) - rank(a));
    keep.push(arr[0]);
    removed += arr.length - 1;
  }

  if (args.dryRun) {
    console.log(`Dry run duplicates removed=${removed} keep=${keep.length}`);
    return;
  }

  const backup = `${input}.dedup.bak`;
  fs.copyFileSync(input, backup);
  const lines = [
    headers.join(','),
    ...keep.map((r) => headers.map((h) => escapeCsv(r[h] ?? '')).join(',')),
  ];
  fs.writeFileSync(input, `${lines.join('\n')}\n`, 'utf8');
  console.log(`Dedup complete. removed=${removed} keep=${keep.length} backup=${backup}`);
}

main();
