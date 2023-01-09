#!/bin/bash

set -ex

apt update
apt -q install -y build-essential libboost-dev libboost-filesystem-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev liblua5.1-0-dev libprotobuf-dev libshp-dev libsqlite3-dev protobuf-compiler rapidjson-dev git wget unzip tmux htop aria2 osmium-tool sysstat brotli gdal-bin cmake
