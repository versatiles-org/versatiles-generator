#!/bin/bash
cd "$(dirname "$0")"

set -e

# machine_type="n2d-highmem-2";  # 16 GB RAM
# machine_type="n2d-highmem-4";  # 32 GB RAM
# machine_type="n2d-highmem-8";  # 64 GB RAM
# machine_type="n2d-highmem-16"; # 128 GB RAM
# machine_type="n2d-highmem-32"; # 256 GB RAM
# machine_type="n2d-highmem-64"; # 512 GB RAM

# file_size * 7 = needed RAM

# Prepare env variables
tile_bbox=""
tile_dst="gs://opencloudtiles/mbtiles/"
tile_name="eu-de-bw"; tile_src="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf"; machine_type="n2d-highcpu-8"
# tile_name="eu-de-be"; tile_src="https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf"; machine_type="n2d-highcpu-8"
# tile_name="eu-de"; tile_src="https://download.geofabrik.de/europe/germany-latest.osm.pbf"; machine_type="n2d-standard-16"
# tile_name="eu"; tile_src="https://download.geofabrik.de/europe-latest.osm.pbf"; machine_type="n2d-highmem-32"
# tile_name="planet"; tile_src="https://planet.osm.org/pbf/planet-latest.osm.pbf.torrent"; machine_type="n2d-highmem-64"

# create VM from image
gcloud compute instances create opencloudtiles-generator \
	--image=opencloudtiles-generator \
	--machine-type=$machine_type \
	--scopes=storage-rw

# Wait till SSH is available
sleep 10
while ! gcloud compute ssh opencloudtiles-generator --command=ls
do
   echo "   SSL not available at VM, trying again..."
	sleep 5
done

# prepare command and run it via SSH
command="export TILE_SRC=\"$tile_src\";export TILE_BBOX=\"$tile_bbox\";export TILE_NAME=\"$tile_name\";"
command="$command; curl -Ls \"https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/3_convert.sh\" | bash"
command="$command; gsutil cp \"~/tilemaker/build/shortbread-tilemaker/data/$tile_name.mbtiles\" \"$tile_dst\""
command="$command; sudo shutdown -P now"

echo "$command"

gcloud compute ssh opencloudtiles-generator --command="$command"

gcloud compute instances delete opencloudtiles-generator --quiet
