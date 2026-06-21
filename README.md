[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

# VersaTiles Generator

The Generator uses [Planetiler](https://github.com/onthegomap/planetiler) and [Shortbread](https://shortbread-tiles.org) to generate vector tiles from [OSM dumps](https://planet.osm.org/pbf/).

To make it even easier, we have prepared a [Docker image](https://github.com/versatiles-org/versatiles-docker/tree/main/versatiles-planetiler) (on [Docker Hub](https://hub.docker.com/r/versatiles/versatiles-planetiler) and [GitHub's ghcr.io](https://github.com/versatiles-org/versatiles-docker/pkgs/container/versatiles-planetiler)) that contains [Planetiler](https://github.com/onthegomap/planetiler), the [Shortbread profile for Planetiler](https://github.com/versatiles-org/versatiles-docker/tree/main/versatiles-planetiler), [VersaTiles](https://github.com/versatiles-org/versatiles-rs) for tile compression and packaging, and scripts to manage it all.

Take a look at [`generate_osm.sh`](https://github.com/versatiles-org/versatiles-generator/blob/main/generate_osm.sh) to see how to fetch and run the Docker container.

## System Requirements

- Debian
- [Docker](https://docs.docker.com/engine/install/)
- Bash (part of Debian coreutils)

## Install

```bash
apt-get update
apt-get upgrade
apt-get install bash tmux
curl -fsSL https://get.docker.com | sh

curl "https://raw.githubusercontent.com/versatiles-org/versatiles-generator/main/generate_osm.sh" -o generate_osm.sh
chmod +x generate_osm.sh
tmux
```

## Run
```
./generate_osm.sh
```
