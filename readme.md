# versatiles - Generator

The Generator uses [Tilemaker](https://github.com/systemed/tilemaker) for generating vector tiles from OSM dumps.

As tile scheme it does not use the [OpenMapTiles schema](https://openmaptiles.org/schema/) because:
- OpenMapTiles it is not "open" enough
- some people have legal problems with CC-BY
- It feels like a SEO campagne for a MapTiler product, because every map has to link to their website, or you have to pay a license fee.

Instead the Generator uses the [Shortbread schema](https://shortbread.geofabrik.de/schema/) from [Geofabrik](https://www.geofabrik.de). It's based on the [Shortbread Tilemaker configuration](https://github.com/geofabrik/shortbread-tilemaker/).

# files

Currently it uses Bash scripts:

## `bin/basic_scripts`

- `1_setup_debian.sh` prepares a debian system and installs:
  - `osmium` for *.osm.pbf preprocessing
  - `aria2` for downloading OSM data, e.g. the planet via torrent
  - some required libs for TileMaker
- `2_prepare_tilemaker.sh` installs Tilemaker and fetches required geo data like water polygons etc.
- `3_convert.sh` downloads a OSM dump with `aria2c`, prepares the data with `osmium renumber` to improve overall processing time and finally converts the data with `tilemaker`.

## `bin/run_google_compute`

scripts for generating vector tiles on a Google Compute VM.

- `1_prepare_image.sh` prepares a VM image (using `1_setup_debian.sh` and `2_prepare_tilemaker.sh`) that can be used for tile generation
- `2_generate_tiles.sh` starts a VM (RAM should be 7 times file size), generates tiles using `3_convert.sh` and uploads the result to Google Storage.

To generate tiles for the whole planet it uses a 64 core VM with 512 GB of RAM. This VM is quite expensive but runs only for a few hours. The total costs are around 10 €.

# environment variables

for convenience the scripts use environment variables:

- `TILE_SRC`: url of OSM data
- `TILE_BBOX`: optional bbox
- `TILE_NAME`: name of the result without extension, e.g. `planet-2023-01-09`
- `TILE_DST`: upload target, e.g. a Google Storage


