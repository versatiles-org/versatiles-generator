#!/bin/bash



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

while true; do
	gcloud compute images describe versatiles-generator &> /dev/null
	if [ $? -eq 0 ]; then
		echo "   ❗️ versatiles-generator image already exist. Delete it?"
		select yn in "Yes" "No"; do
			case $yn in
				Yes)
					echo "   👷 deleting image ..."
					gcloud compute images delete versatiles-generator -q;
					break;;
				No) exit;;
			esac
		done
	else
		echo "   ✅ gcloud image free"
		break
	fi
done



##########################################
## BUILD VM                             ##
##########################################

echo "   👷 building vm"

# Create VM
gcloud compute instances create versatiles-generator \
	--image-project=debian-cloud \
	--image-family=debian-11 \
	--boot-disk-size=300GB \
	--boot-disk-type=pd-ssd \
	--machine-type=n2d-highcpu-8

# Wait till SSH is available
sleep 10
while ! gcloud compute ssh versatiles-generator --command=ls
do
   echo "   SSL not available at VM, trying again..."
	sleep 5
done

# Setup machine
gcloud compute ssh versatiles-generator --command='curl -Ls "https://github.com/versaTiles/versatiles-generator/raw/main/bin/basic_scripts/1_setup_debian.sh" | sudo bash'

# Setup tilemaker
gcloud compute ssh versatiles-generator --command='curl -Ls "https://github.com/versaTiles/versatiles-generator/raw/main/bin/basic_scripts/2_prepare_tilemaker.sh" | bash'



##########################################
## GENERATE IMAGE                       ##
##########################################

# Stop VM
gcloud compute instances stop versatiles-generator
sleep 5



echo "   👷 building image"

# Generate image
gcloud compute images create versatiles-generator --source-disk=versatiles-generator



echo "   👷 cleaning up"

# Delete Instance
gcloud compute instances delete versatiles-generator --quiet
