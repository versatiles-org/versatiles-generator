#!/bin/bash
cd "$(dirname "$0")"

# set -e

# machine_type="n2d-highmem-2";  # 16 GB RAM
# machine_type="n2d-highmem-4";  # 32 GB RAM
# machine_type="n2d-highmem-8";  # 64 GB RAM
# machine_type="n2d-highmem-16"; # 128 GB RAM
# machine_type="n2d-highmem-32"; # 256 GB RAM
# machine_type="n2d-highmem-64"; # 512 GB RAM

# file_size * 7 = needed RAM

# Prepare env variables
tile_bbox=""

COLUMNS=1
select source in "Berlin" "Baden-Württemberg" "Germany" "Europe" "Planet"; do
	case $source in
		"Berlin") # 0:01:22 = 0.01$
			date=$(curl -s "https://download.geofabrik.de/europe/germany/berlin.html" | egrep -o 'href="berlin-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			tile_src="https://download.geofabrik.de/europe/germany/berlin-$date.osm.pbf"
			tile_dst="gs://versatiles/download/planet/europe/germany/berlin-20$date.mbtiles"
			machine_type="n2d-highcpu-8"
			break;;
		"Baden-Württemberg") # 0:03:05 = 0.02 $
			date=$(curl -s "https://download.geofabrik.de/europe/germany/baden-wuerttemberg.html" | egrep -o 'href="baden-wuerttemberg-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			tile_src="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-$date.osm.pbf"
			tile_dst="gs://versatiles/download/planet/europe/germany/bw-20$date.mbtiles"
			machine_type="n2d-highcpu-8"
			break;;
		"Germany") # 0:11:13 = 0.14 $
			date=$(curl -s "https://download.geofabrik.de/europe/germany.html" | egrep -o 'href="germany-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			tile_src="https://download.geofabrik.de/europe/germany-$date.osm.pbf"
			tile_dst="gs://versatiles/download/planet/europe/germany/germany-20$date.mbtiles"
			machine_type="n2d-standard-16"
			break;;
		"Europe")
			date=$(curl -s "https://download.geofabrik.de/europe.html" | egrep -o 'href="europe-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			tile_src="https://download.geofabrik.de/europe-$date.osm.pbf"
			tile_dst="gs://versatiles/download/planet/europe/europe-20$date.mbtiles"
			machine_type="n2d-highmem-32"
			break;;
		"Planet") # 11:18:20 = 42.50 $
			date=$(curl -s "https://planet.osm.org/pbf/" | egrep -o 'href="planet-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			tile_src="https://planet.osm.org/pbf/planet-$date.osm.pbf.torrent"
			tile_dst="gs://versatiles/download/planet/planet-20$date.mbtiles"
			machine_type="n2d-highmem-80"
			tile_bbox="-180,-86,180,86"
			break;;
	esac
done



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

while true; do
	gcloud compute instances describe versatiles-generator &> /dev/null
	if [ $? -eq 0 ]; then
		echo "   ❗️ versatiles-generator machine already exist. Delete it?"
		select yn in "Yes" "No"; do
			case $yn in
				Yes)
					echo "   👷 deleting machine ..."
					gcloud compute instances delete versatiles-generator -q;
					break;;
				No) exit;;
			esac
		done
	else
		echo "   ✅ gcloud instance free"
		break
	fi
done

value=$(gcloud compute images describe versatiles-generator &> /dev/null)
if [ $? -ne 0 ]; then
	echo "   ❗️ versatiles-generator image does not exist. Create it:"
	echo "   # ./1_prepare_image.sh"
	exit 1
else
	echo "   ✅ gcloud image ready"
fi

set -ex

# create VM from image
gcloud compute instances create versatiles-generator \
	--image=versatiles-generator \
	--machine-type=$machine_type \
	--scopes=storage-rw

# Wait till SSH is available
sleep 10
while ! gcloud compute ssh versatiles-generator --command=ls; do
	echo "   SSL not available at VM, trying again..."
	sleep 5
done

# prepare command and run it via SSH
command="export TILE_SRC=\"$tile_src\";export TILE_BBOX=\"$tile_bbox\""
command="$command; curl -Ls \"https://github.com/versatiles-org/versatiles-generator/raw/main/bin/basic_scripts/3_convert.sh\" | bash"
command="$command; gsutil cp \"shortbread-tilemaker/data/output.mbtiles\" \"$tile_dst\""

gcloud compute ssh versatiles-generator --command="$command" -- -t

gcloud compute instances stop versatiles-generator --quiet

gcloud compute instances delete versatiles-generator --quiet
