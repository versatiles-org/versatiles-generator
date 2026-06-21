#!/bin/bash
set -e


docker run -it --rm \
	--mount="type=bind,source=$(pwd)/result,target=/app/data" \
	versatiles/versatiles-planetiler \
	--area "planet" \
	--checksum

