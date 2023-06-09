#!/bin/bash
set -ex

cd ~
git clone -q https://github.com/systemed/tilemaker.git tilemaker
cd tilemaker
make "CONFIG=-DFLOAT_Z_ORDER"
sudo make install

cd ~
git clone -q https://github.com/versatiles-org/shortbread-tilemaker shortbread-tilemaker
cd shortbread-tilemaker
./get-shapefiles.sh
