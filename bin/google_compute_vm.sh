#!/bin/bash
cd "$(dirname "$0")"

# List of machine types in your zone
#    gcloud compute machine-types list --zones europe-west3-c

machine_type="n2d-highmem-2";  disk_space="300GB" # 16 GB RAM
#machine_type="n2d-highmem-4";  disk_space="60GB"  # 32 GB RAM
#machine_type="n2d-highmem-8";  disk_space="120GB" # 64 GB RAM
#machine_type="n2d-highmem-16"; disk_space="250GB" # 128 GB RAM
#machine_type="n2d-highmem-32"; disk_space="500GB" # 256 GB RAM


# List of images
#    gcloud compute images list

gcloud compute instances create opencloudtiles-generator \
	--image-project=debian-cloud \
	--image-family=debian-11 \
	--boot-disk-size=$disk_space \
	--machine-type=$machine_type
