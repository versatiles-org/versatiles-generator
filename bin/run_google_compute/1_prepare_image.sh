#!/bin/bash

set -e



##########################################
## CHECK GCLOUD CONFIGURATION           ##
##########################################

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

value=$(gcloud compute instances describe opencloudtiles-generator > /dev/null)
if [ $? -eq 0 ]; then
	echo "   ❗️ opencloudtiles-generator machine already exist. Delete it:"
	echo "   # gcloud compute instances delete opencloudtiles-generator -q"
	exit 1
else
	echo "   ✅ gcloud instance ready"
fi

value=$(gcloud compute images describe opencloudtiles-generator > /dev/null)
if [ $? -eq 0 ]; then
	echo "   ❗️ opencloudtiles-generator image already exist. Delete it:"
	echo "   # gcloud compute images delete opencloudtiles-generator -q"
	exit 1
else
	echo "   ✅ gcloud image clean"
fi



##########################################
## BUILD VM                             ##
##########################################

# Create VM
gcloud compute instances create opencloudtiles-generator \
	--image-project=debian-cloud \
	--image-family=debian-11 \
	--boot-disk-size=300GB \
	--boot-disk-type=pd-ssd \
	--machine-type=n2d-standard-2

# Wait till SSH is available
sleep 10
while ! gcloud compute ssh opencloudtiles-generator --command=ls
do
   echo "   SSL not available at VM, trying again..."
	sleep 5
done

# Setup machine
gcloud compute ssh opencloudtiles-generator --command='curl -Ls "https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/1_setup_debian.sh" | sudo bash'

# Setup tilemaker
gcloud compute ssh opencloudtiles-generator --command='curl -Ls "https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/2_prepare_tilemaker.sh" | bash'



##########################################
## GENERATE IMAGE                       ##
##########################################

# Stop VM
gcloud compute instances stop opencloudtiles-generator

# Generate image
gcloud compute images create opencloudtiles-generator --source-disk=opencloudtiles-generator

# Delete Instance
gcloud compute instances delete opencloudtiles-generator --quiet
