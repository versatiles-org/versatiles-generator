#!/bin/bash
cd "$(dirname "$0")"

set -ex

# List of machine types in your zone and images
#    gcloud compute machine-types list --zones europe-west3-c
#    gcloud compute images list

# machine_type="n2d-highmem-2";  disk_space="200GB"  # 16 GB RAM
# machine_type="n2d-highmem-4";  disk_space="200GB"  # 32 GB RAM
# machine_type="n2d-highmem-8";  disk_space="200GB" # 64 GB RAM
# machine_type="n2d-highmem-16"; disk_space="250GB" # 128 GB RAM
# machine_type="n2d-highmem-32"; disk_space="500GB" # 256 GB RAM


# size * 6 = RAM

# tile_name="eu-de-bw"; tile_src="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf"; machine_type="n2d-highcpu-4"; disk_space="200GB"
tile_name="eu-de-be"; tile_src="https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf"; machine_type="n2d-highcpu-8"; disk_space="200GB"
# tile_name="eu-de"; tile_src="https://download.geofabrik.de/europe/germany/https://download.geofabrik.de/europe/germany-latest.osm.pbf"; machine_type="n2d-highcpu-16"; disk_space="200GB"
# tile_name="eu"; tile_src="https://download.geofabrik.de/europe-latest.osm.pbf"; machine_type="n2d-standard-64"; disk_space="250GB"
# tile_name="planet"; tile_src="https://planet.osm.org/pbf/planet-latest.osm.pbf.torrent"; machine_type="n2d-standard-64"; disk_space="250GB"


tile_bbox=""
tile_dst="gs://opencloudtiles/mbtiles/"

gcloud compute instances create opencloudtiles-generator \
	--image-project=debian-cloud \
	--image-family=debian-11 \
	--boot-disk-size=$disk_space \
	--boot-disk-type=pd-ssd \
	--machine-type=$machine_type \
	--zone=europe-west3-c \
	--scopes=storage-rw \
	--metadata \
	TILE_SRC="$tile_src",TILE_BBOX="$tile_bbox",TILE_NAME="$tile_name",TILE_DST="$tile_dst"

sleep 10

gcloud compute ssh opencloudtiles-generator --zone europe-west3-c --command='curl -L "https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/startup-scripts/run_google_compute_vm.sh" | bash'
