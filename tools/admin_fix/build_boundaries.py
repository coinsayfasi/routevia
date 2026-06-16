#!/usr/bin/env python3
"""Build simplified province/district boundary WKT mapped to DB ids -> boundaries.json"""
import json, re, unicodedata, collections
from shapely.geometry import shape
from shapely import wkt as shwkt

def norm(s):
    if not s: return ""
    repl = {"İ":"i","I":"i","ı":"i","Ş":"s","ş":"s","Ğ":"g","ğ":"g","Ü":"u","ü":"u","Ö":"o","ö":"o","Ç":"c","ç":"c"}
    s = "".join(repl.get(c,c) for c in s).lower()
    return re.sub(r"[^a-z0-9]","",unicodedata.normalize("NFKD", s).encode("ascii","ignore").decode())

provinces = json.load(open("provinces.json"))
prov_by_norm = {norm(p["name"]): p for p in provinces}
dcoords = json.load(open("districts_coords.json"))
dist_lookup = {}
for d in dcoords:
    dist_lookup[(d["province_id"], norm(d["name"]))] = d

TOL = 0.0008  # ~80m simplification; plenty for POI point-in-polygon

def simp(geom):
    g = geom.simplify(TOL, preserve_topology=True)
    if g.is_empty or not g.is_valid:
        g = geom.buffer(0).simplify(TOL, preserve_topology=True)
    return g

il = json.load(open("tr_l4.geojson"))
out_prov = {}
plate_prov = {}
for f in il["features"]:
    p = f["properties"]
    if p.get("network") != "TR-provinces": continue
    nm = re.sub(r"\s*İli$","", p.get("name:tr") or p.get("name"))
    dbp = prov_by_norm.get(norm(nm))
    if not dbp: continue
    out_prov[dbp["id"]] = simp(shape(f["geometry"])).wkt
    m = re.match(r"TR-(\d+)", p.get("ISO3166-2",""))
    if m: plate_prov[int(m.group(1))] = dbp

# Iğdır (and any missing) from alpers
alp = json.load(open("alpers_il.geojson"))
for f in alp["features"]:
    dbp = prov_by_norm.get(norm(f["properties"]["name"]))
    if dbp and dbp["id"] not in out_prov:
        out_prov[dbp["id"]] = simp(shape(f["geometry"])).wkt
print("province polygons mapped:", len(out_prov), "/ 81")

# districts: name-match (merkez-aware) within province
ilce = json.load(open("tr_l6.geojson"))
out_dist = {}
unmatched = 0
for f in ilce["features"]:
    p = f["properties"]; m = re.match(r"TR(\d+)-districts", p.get("network",""))
    if not m: continue
    dbp = plate_prov.get(int(m.group(1)))
    if not dbp: continue
    dn = norm(p.get("name"))
    d = dist_lookup.get((dbp["id"], dn))
    if not d and ("merkez" in dn or dn == norm(dbp["name"])):
        d = dist_lookup.get((dbp["id"], "merkez"))
    if not d:
        unmatched += 1; continue
    g = simp(shape(f["geometry"]))
    if d["id"] in out_dist:  # merge multiple polygons for same district
        prev = shwkt.loads(out_dist[d["id"]]["wkt"])
        g = simp(prev.union(g))
    out_dist[d["id"]] = {"pid": dbp["id"], "wkt": g.wkt}
print("district polygons mapped:", len(out_dist), " unmatched OSM polys:", unmatched)

json.dump({"provinces": [{"id": k, "wkt": v} for k, v in out_prov.items()],
           "districts": [{"id": k, "pid": v["pid"], "wkt": v["wkt"]} for k, v in out_dist.items()]},
          open("boundaries.json", "w"))
import os
print("boundaries.json size MB:", round(os.path.getsize("boundaries.json")/1e6, 2))
