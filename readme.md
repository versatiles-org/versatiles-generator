# versatiles - Generator

The Generator uses [Tilemaker](https://github.com/systemed/tilemaker) for generating vector tiles from OSM dumps.

Requires:
- Debian
- docker
- Bash, md5sum, sha256sum
- `apt -qy install lftp`

## Run

```bash
curl "https://raw.githubusercontent.com/versatiles-org/versatiles-generator/main/bin/generate_osm.sh" | bash -i
```