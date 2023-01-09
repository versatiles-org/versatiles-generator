#!/bin/bash

cd ~/tilemaker/build/shortbread-tilemaker

aria2c -o "$TILE_NAME.osm.pbf" --seed-time=0 $TILE_SRC

if [ $TILE_BBOX -ge 1 ]
then
	../tilemaker --bbox $TILE_BBOX --input "$TILE_NAME.osm.pbf" --store tilemaker-cache.dat --config config.json --process process.lua --output "$TILE_NAME.mbtiles" --store ./tmp --compact
else
	../tilemaker --input "$TILE_NAME.osm.pbf" --store tilemaker-cache.dat --config config.json --process process.lua --output "$TILE_NAME.mbtiles" --store ./tmp --compact
fi
