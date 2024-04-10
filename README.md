# VersaTiles Generator

The Generator uses [Tilemaker](https://tilemaker.org) and [Shortbread](https://shortbread-tiles.org) to generate vector tiles from [OSM dumps](https://planet.osm.org/pbf/).

To make it even easier, we have prepared a [Docker image](https://github.com/versatiles-org/versatiles-docker) (on [Docker Hub](https://hub.docker.com/r/versatiles/versatiles-tilemaker) and [GitHub's ghcr.io](https://github.com/versatiles-org/versatiles-docker/pkgs/container/versatiles-tilemaker)) that contains [Tilemaker](https://github.com/systemed/tilemaker), the [Shortbread configuration for Tilemaker](https://github.com/versatiles-org/shortbread-tilemaker), [additional geometries](https://github.com/versatiles-org/shortbread-tilemaker/blob/versatiles/get-shapefiles.sh), [VersaTiles](https://github.com/versatiles-org/versatiles-rs) for tile compression and packaging, and scripts to manage it all.

Take a look at the bottom of [`bin/generate_osm.sh`](https://github.com/versatiles-org/versatiles-generator/blob/main/bin/generate_osm.sh#L40) to see how to fetch and run the Docker container.

Since we use this script to generate our tiles, we also use `lftp` in the last line to upload the results.

## System Requirements

- Debian
- Docker
- Bash, md5sum, sha256sum
- `apt -qy install lftp` (if you want to upload the results via FTP)

## Run

```bash
curl "https://raw.githubusercontent.com/versatiles-org/versatiles-generator/main/bin/generate_osm.sh" | bash -i
```
