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

# Create VM

sleep 10
while ! gcloud compute ssh opencloudtiles-generator --command=ls
do
   echo "   SSL not available at VM, trying again..."
	sleep 5
done


gcloud compute ssh opencloudtiles-generator --command='curl -Ls "https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/1_setup_debian.sh" | bash'

gcloud compute ssh opencloudtiles-generator --command='curl -Ls "https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin/basic_scripts/2_prepare_tilemaker.sh" | bash'


##########################################
## GENERATE CUSTOM IMAGE                ##
##########################################
# source: https://cloud.google.com/compute/docs/images/create-custom

gcloud compute images describe opencloudtiles --project=swr-data-1



gcloud compute instances delete opencloudtiles-generator