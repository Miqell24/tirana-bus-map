# Tirana Public Transport — interactive map

Interactive, poster-grade map of the whole public transport network of
**Tirana**: 27 bus lines — 297 stops, 400 km, weighted mean matching error
0.28 m, the tightest fit in the family.

## Live

Local build on port 8170 (`npm run serve`).

Everything comes from ONE feed published by the **Municipality of Tirana**
(pt.tirana.al, CC-BY-SA), with shapes. The Mobility Database mirrors the same
file as mdb-2345 and `download.sh` falls back to it when the producer is down.

| mode | route_type | graph |
|---|---|---|
| buses | 3 | OSM roadways |

Tirana has no tram, no trolleybus and no metro, so this is the entire public
network of the city. Line numbers carry a letter for the branch (1A, 3B, 12A
and 12B) exactly as the buses do.

Of 490 stop names only fourteen shout, and each is an acronym the city itself
shouts (TEG, QTU, PTUU), so nothing was rewritten.

## Pipeline

`npm run download` fetches the feed and cuts the OSM extract. **The OSM
data comes from Geofabrik, not Overpass** — the public mirrors were answering
504 to every request on the day this map was built, even for a single small
city box — so `pipeline/pbf-tiles.py` (needs `pip3 install --user osmium`)
clips the tiles out of `albania-latest.osm.pbf`, writing exactly the JSON shape Overpass would
have returned, node ids included.

`npm run build` map-matches every line (HMM/Viterbi on the OSM graph) and
writes GeoJSON to `data/out/`; `npm run lines` adds the line-by-line view.
`npm run serve` hosts the map at <http://localhost:8170>.

Data: Bashkia e Tiranës (CC-BY-SA) ·
base map © OpenFreeMap / OpenMapTiles / OpenStreetMap contributors.
