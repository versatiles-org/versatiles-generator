#!/bin/bash
cd ~/shortbread-tilemaker/data/

set -ex

aria2c --seed-time=0 "$TILE_SRC"

pbf_files=$(ls *.pbf)
if [ $(echo $pbf_files | wc -l) -ne 1 ]
then
	echo "There should be only one PBF file"
	exit 1
fi
eval "mv '$pbf_files' 'input.osm.pbf'"

osmium renumber --progress -o prepared.osm.pbf input.osm.pbf

rm input.osm.pbf

cd ~/shortbread-tilemaker/

if [ ${#TILE_BBOX} -ge 1 ]
then
	time tilemaker --input data/prepared.osm.pbf --config config.json --process process.lua --output "data/output.mbtiles" --compact --bbox $TILE_BBOX
else
   time tilemaker --input data/prepared.osm.pbf --config config.json --process process.lua --output "data/output.mbtiles" --compact
fi
