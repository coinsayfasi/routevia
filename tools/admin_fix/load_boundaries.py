#!/usr/bin/env python3
"""Create + load admin boundary polygon tables into live DB via Management API."""
import json, os, time, urllib.request, urllib.error
REF = "xfswonqskciufcnsehfc"; PAT = os.environ["SUPA_PAT"]
URL = f"https://api.supabase.com/v1/projects/{REF}/database/query"
def run(sql):
    req = urllib.request.Request(URL, data=json.dumps({"query": sql}).encode(),
        headers={"Authorization": f"Bearer {PAT}", "Content-Type": "application/json", "User-Agent": "curl/8.4.0"})
    try: return json.loads(urllib.request.urlopen(req, timeout=180).read().decode())
    except urllib.error.HTTPError as e: raise RuntimeError(f"HTTP {e.code}: {e.read().decode()[:400]}")

b = json.load(open("boundaries.json"))

run("""
drop table if exists public.admin_boundaries_district;
drop table if exists public.admin_boundaries_province;
create table public.admin_boundaries_province(
  province_id uuid primary key references public.provinces(id) on delete cascade,
  geom geometry(Geometry,4326) not null);
create table public.admin_boundaries_district(
  district_id uuid primary key references public.districts(id) on delete cascade,
  province_id uuid not null references public.provinces(id) on delete cascade,
  geom geometry(Geometry,4326) not null);
""")
print("tables created")

def esc(w): return w.replace("'", "''")

# provinces (5 per batch)
rows = b["provinces"]; done = 0
for i in range(0, len(rows), 5):
    vals = ",".join(f"('{r['id']}'::uuid, ST_MakeValid(ST_GeomFromText('{esc(r['wkt'])}',4326)))" for r in rows[i:i+5])
    run(f"insert into public.admin_boundaries_province(province_id,geom) values {vals};")
    done += len(rows[i:i+5]); print(f"  province {done}/{len(rows)}"); time.sleep(0.1)

# districts (8 per batch)
rows = b["districts"]; done = 0
for i in range(0, len(rows), 8):
    vals = ",".join(f"('{r['id']}'::uuid,'{r['pid']}'::uuid, ST_MakeValid(ST_GeomFromText('{esc(r['wkt'])}',4326)))" for r in rows[i:i+8])
    run(f"insert into public.admin_boundaries_district(district_id,province_id,geom) values {vals};")
    done += len(rows[i:i+8]); print(f"  district {done}/{len(rows)}"); time.sleep(0.1)

run("""
create index if not exists abp_geom_gix on public.admin_boundaries_province using gist(geom);
create index if not exists abd_geom_gix on public.admin_boundaries_district using gist(geom);
create index if not exists abd_prov_idx on public.admin_boundaries_district(province_id);
analyze public.admin_boundaries_province;
analyze public.admin_boundaries_district;
""")
print(run("select (select count(*) from public.admin_boundaries_province) p, (select count(*) from public.admin_boundaries_district) d;"))
