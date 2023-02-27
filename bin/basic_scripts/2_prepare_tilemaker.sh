#!/bin/bash
set -ex

cd ~
git clone -q --branch z-order-float https://github.com/geofabrik/tilemaker.git tilemaker
cd tilemaker
make -s
sudo make install

cd ~
git clone -q https://github.com/versatiles-org/shortbread-tilemaker shortbread-tilemaker
cd shortbread-tilemaker
./get-shapefiles.sh
