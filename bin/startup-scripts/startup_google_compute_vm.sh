#!/bin/bash

script_src="https://github.com/OpenCloudTiles/opencloudtiles-generator/raw/main/bin"
env_file="/etc/profile"

function get_env() {
	key=$1
	value=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/$key" -H "Metadata-Flavor: Google")
	cmd="export $key=\"$value\""
	echo "$cmd" >> $env_file
	eval "$cmd"
}

get_env "TILE_SRC"
get_env "TILE_BBOX"
get_env "TILE_NAME"
get_env "TILE_DST"

source $env_file

curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes" -H "Metadata-Flavor: Google"

curl "$script_src/processing-scripts/1_setup.sh" | bash
