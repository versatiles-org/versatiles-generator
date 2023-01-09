#!/bin/bash
cd ~

git clone --branch z-order-float https://github.com/geofabrik/tilemaker.git
cd tilemaker
mkdir build
cd build
cmake ..
make

mkdir shortbread-tilemaker
git clone https://github.com/geofabrik/shortbread-tilemaker.git shortbread-tilemaker
cd shortbread-tilemaker
./get-shapefiles.sh

