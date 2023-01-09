#!/bin/bash
cd "$(dirname "$0")"

set -ex

# List of machine types in your zone and images
#    gcloud compute machine-types list --zones europe-west3-c
#    gcloud compute images list

machine_type="n2d-highmem-2";  disk_space="30GB"  # 16 GB RAM
#machine_type="n2d-highmem-4";  disk_space="60GB"  # 32 GB RAM
#machine_type="n2d-highmem-8";  disk_space="120GB" # 64 GB RAM
#machine_type="n2d-highmem-16"; disk_space="250GB" # 128 GB RAM
#machine_type="n2d-highmem-32"; disk_space="500GB" # 256 GB RAM

#tile_src="https://planet.osm.org/pbf/planet-latest.osm.pbf.torrent"
tile_src="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf"
tile_bbox=""
tile_name="eu-de-bw"
tile_dst="gs://opencloudtiles/"

gcloud compute instances create opencloudtiles-generator \
	--image-project=debian-cloud \
	--image-family=debian-11 \
	--boot-disk-size=$disk_space \
	--machine-type=$machine_type \
	--zone=europe-west3-c \
	--scopes=storage-rw \
	--metadata \
	tile_src="$tile_src",tile_bbox="$tile_bbox",tile_name="$tile_name",tile_dst="$tile_dst",startup-script-url="https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/startup-scripts/startup_google_compute_vm.sh"