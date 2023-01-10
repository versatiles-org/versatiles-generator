#!/bin/bash
cd ~

set -ex

git clone -q --branch z-order-float https://github.com/geofabrik/tilemaker.git
cd tilemaker
mkdir build
cd build
cmake ..
make -s

mkdir shortbread-tilemaker
git clone -q https://github.com/geofabrik/shortbread-tilemaker.git shortbread-tilemaker
cd shortbread-tilemaker
./get-shapefiles.sh
