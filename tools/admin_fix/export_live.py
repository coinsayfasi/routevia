#!/usr/bin/env python3
"""Export live pois + provinces + districts from Supabase via PostgREST (service role, read-only)."""
import os, json, time, urllib.request, urllib.parse

BASE = os.environ["SUPABASE_URL"].rstrip("/") + "/rest/v1"
KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]
H = {"apikey": KEY, "Authorization": f"Bearer {KEY}"}

def fetch_all(table, select, page=1000):
    out, start = [], 0
    while True:
        q = urllib.parse.urlencode({"select": select})
        req = urllib.request.Request(f"{BASE}/{table}?{q}", headers={**H, "Range-Unit": "items", "Range": f"{start}-{start+page-1}"})
        with urllib.request.urlopen(req) as r:
            chunk = json.load(r)
        out.extend(chunk)
        if len(chunk) < page:
            break
        start += page
        time.sleep(0.05)
    return out

if __name__ == "__main__":
    pois = fetch_all("pois", "id,name,lat,lng,city,district,provenance_verified")
    json.dump(pois, open("pois.json", "w"), ensure_ascii=False)
    print("pois:", len(pois))
    provs = fetch_all("provinces", "id,name,slug")
    json.dump(provs, open("provinces.json", "w"), ensure_ascii=False)
    print("provinces:", len(provs))
    dists = fetch_all("districts", "id,name,slug,province_id")
    json.dump(dists, open("districts.json", "w"), ensure_ascii=False)
    print("districts:", len(dists))
    pc = fetch_all("places_clean", "id,name,province_id,district_id")
    json.dump(pc, open("places_clean.json", "w"), ensure_ascii=False)
    print("places_clean:", len(pc))
