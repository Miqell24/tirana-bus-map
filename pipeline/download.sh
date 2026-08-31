#!/usr/bin/env bash
# Downloads input data: the Tirana GTFS, the OSM extract, MapLibre GL.
# Everything is cached — re-running only fetches what is missing.
#
# The Municipality of Tirana publishes the city network at pt.tirana.al
# (CC-BY-SA); the Mobility Database mirrors the same file as mdb-2345 and is
# used as the fallback when the producer is down.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p data/gtfs data/osm/tiles web/vendor

# pyosmium does the cutting; it is the one dependency outside Node here.
need_osmium () {
  python3 -c "import osmium" 2>/dev/null && return 0
  echo "brak pakietu osmium — zainstaluj: pip3 install --user osmium" >&2
  return 1
}

# 1) GTFS
if [ ! -f data/gtfs/routes.txt ]; then
  echo "== Tirana GTFS =="
  curl -fL --retry 3 --max-time 600 -o data/tirana-gtfs.zip "https://pt.tirana.al/gtfs/gtfs.zip" \
    || curl -fL --retry 3 --max-time 600 -o data/tirana-gtfs.zip "https://files.mobilitydatabase.org/mdb-2345/latest.zip"
  unzip -o data/tirana-gtfs.zip -d data/gtfs
fi

# 2) OSM — from the Geofabrik extract, not Overpass.
#    Tirana is one 10 x 15 km tile out of the Albanian Geofabrik extract.
#    pipeline/pbf-tiles.py cuts the tiles out of the .pbf and writes exactly the
#    JSON shape Overpass would have returned (ways with tags, NODE IDS and
#    geometry — buildGraph silently drops ways without el.nodes).
if [ ! -f data/osm/tiles/t1.json ]; then
  need_osmium
  if [ ! -f data/albania-latest.osm.pbf ]; then
    echo "== Geofabrik albania-latest.osm.pbf =="
    curl -fL --retry 5 --retry-delay 5 -C - --max-time 3600 -o data/albania-latest.osm.pbf \
      "https://download.geofabrik.de/europe/albania-latest.osm.pbf"
  fi
  echo "== cutting OSM tiles out of the extract =="
  python3 pipeline/pbf-tiles.py
fi

# 3) MapLibre GL (vendored, no CDN at runtime)
if [ ! -f web/vendor/maplibre-gl.js ]; then
  echo "== MapLibre GL =="
  curl -fL --retry 3 -o web/vendor/maplibre-gl.js  https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.js
  curl -fL --retry 3 -o web/vendor/maplibre-gl.css https://unpkg.com/maplibre-gl@5.6.1/dist/maplibre-gl.css
fi

echo "OK — data ready:"
du -sh data/gtfs data/osm 2>/dev/null || true
