#!/bin/bash
cd ~/tilemaker/build/shortbread-tilemaker

set -ex

aria2c -o "$TILE_NAME.osm.pbf" --seed-time=0 "$TILE_SRC"

osmium renumber --progress -o temp.osm.pbf "$TILE_NAME.osm.pbf"

if [ ${#TILE_BBOX} -ge 1 ]
then
	../tilemaker --bbox $TILE_BBOX --input temp.osm.pbf --config config.json --process process.lua --output "$TILE_NAME.mbtiles" --compact
else
   ../tilemaker --input temp.osm.pbf --config config.json --process process.lua --output "$TILE_NAME.mbtiles" --compact
fi
