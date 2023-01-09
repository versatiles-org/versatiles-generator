#!/bin/bash

script_src="https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin"
env_file="/etc/profile"

function get_env() {
	kex=$1
	value=$("http://metadata.google.internal/computeMetadata/v1/instance/attributes/$key" -H "Metadata-Flavor: Google")
	echo "export $key=\"$value\"" >> $env_file
}

get_env "tile_src"
get_env "tile_bbox"
get_env "tile_name"
get_env "tile_dst"

source $env_file

curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes" -H "Metadata-Flavor: Google"

curl "$script_src/processing-scripts/1_setup.sh" | bash
