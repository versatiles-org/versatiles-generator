#!/bin/bash
cd "$(dirname "$0")"

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
# tile_name="eu-de-be"; tile_src="https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf"; machine_type="n2d-highcpu-8"   # 1:22 = 0.01 $
# tile_name="eu-de-bw"; tile_src="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf"; machine_type="n2d-highcpu-8"   # 3:05 = 0.02 $
# tile_name="eu-de"; tile_src="https://download.geofabrik.de/europe/germany-latest.osm.pbf"; machine_type="n2d-standard-16"   # 11:13 = 0.14 $
# tile_name="eu"; tile_src="https://download.geofabrik.de/europe-latest.osm.pbf"; machine_type="n2d-highmem-32"
tile_name="planet"; tile_src="https://planet.osm.org/pbf/planet-latest.osm.pbf.torrent"; machine_type="n2d-highmem-64"


value=$(gcloud config get-value project)
if [[ $value = "" ]]; then
	echo "   ❗️ set a default project in gcloud, e.g.:"
	echo "   # gcloud config set project PROJECT_ID"
	echo "   ❗️ see also: https://cloud.google.com/artifact-registry/docs/repositories/gcloud-defaults#project"
	exit 1
else
	echo "   ✅ gcloud project: $value"
fi

value=$(gcloud config get-value compute/region)
if [[ $value = "" ]]; then
	echo "   ❗️ set a default compute/region in gcloud, e.g.:"
	echo "   # gcloud config set compute/region europe-west3"
	echo "   ❗️ see also: https://cloud.google.com/compute/docs/gcloud-compute#set_default_zone_and_region_in_your_local_client"
	exit 1
else
	echo "   ✅ gcloud compute/region: $value"
fi

value=$(gcloud config get-value compute/zone)
if [[ $value = "" ]]; then
	echo "   ❗️ set a default compute/zone in gcloud, e.g.:"
	echo "   # gcloud config set compute/zone europe-west3-c"
	echo "   ❗️ see also: https://cloud.google.com/compute/docs/gcloud-compute#set_default_zone_and_region_in_your_local_client"
	exit 1
else
	echo "   ✅ gcloud compute/zone: $value"
fi

value=$(gcloud compute instances describe opencloudtiles-generator)
if [ $? -eq 0 ]; then
	echo "   ❗️ opencloudtiles-generator machine already exist. Delete it:"
	echo "   # gcloud compute instances delete opencloudtiles-generator -q"
	exit 1
else
	echo "   ✅ gcloud instance ready"
fi

set -ex

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
command="export TILE_SRC=\"$tile_src\";export TILE_BBOX=\"$tile_bbox\";export TILE_NAME=\"$tile_name\""
command="$command; curl -Ls \"https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/3_convert.sh\" | bash"
command="$command; gsutil cp \"tilemaker/build/shortbread-tilemaker/data/$tile_name.mbtiles\" \"$tile_dst\""

gcloud compute ssh opencloudtiles-generator --command="$command" -- -t

gcloud compute instances stop opencloudtiles-generator --quiet

gcloud compute instances delete opencloudtiles-generator --quiet
