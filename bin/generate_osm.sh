#!/bin/bash
set -e

COLUMNS=1
select source in "Berlin" "Baden-Württemberg" "Germany" "Europe" "Planet"; do
	case $source in
		"Berlin")
			DATE=$(curl -s "https://download.geofabrik.de/europe/germany/berlin.html" | egrep -o 'href="berlin-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			TILE_URL="https://download.geofabrik.de/europe/germany/berlin-$DATE.osm.pbf"
			TILE_NAME="osm.berlin.20$DATE"
			TILE_BBOX="13.0,52.3,13.8,52.7"
			break;;
		"Baden-Württemberg")
			DATE=$(curl -s "https://download.geofabrik.de/europe/germany/baden-wuerttemberg.html" | egrep -o 'href="baden-wuerttemberg-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			TILE_URL="https://download.geofabrik.de/europe/germany/baden-wuerttemberg-$DATE.osm.pbf"
			TILE_NAME="osm.bw.20$DATE"
			TILE_BBOX="7.5,47.5,10.6,49.8"
			break;;
		"Germany")
			DATE=$(curl -s "https://download.geofabrik.de/europe/germany.html" | egrep -o 'href="germany-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			TILE_URL="https://download.geofabrik.de/europe/germany-$DATE.osm.pbf"
			TILE_NAME="osm.germany.20$DATE"
			TILE_BBOX="5.8,47.2,15.1,55.2"
			break;;
		"Europe")
			DATE=$(curl -s "https://download.geofabrik.de/europe.html" | egrep -o 'href="europe-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			TILE_URL="https://download.geofabrik.de/europe-$DATE.osm.pbf"
			TILE_NAME="osm.europe.20$DATE"
			TILE_BBOX="-34.5,29.6,46.8,81.5"
			break;;
		"Planet")
			DATE=$(curl -s "https://planet.osm.org/pbf/" | egrep -o 'href="planet-([0-9]{6}).osm.pbf"' | sed -n 's/.*-\([0-9]\{6\}\)\..*/\1/p' | sort | tail -n1)
			TILE_URL="https://planet.osm.org/pbf/planet-$DATE.osm.pbf.torrent"
			TILE_NAME="osm.20$DATE"
			TILE_BBOX="-180,-86,180,86"
			break;;
	esac
done

docker pull versatiles/versatiles-tilemaker
docker run -it --rm --privileged --mount="type=bind,source=$(pwd),target=/app/result" versatiles/versatiles-tilemaker generate_tiles.sh $TILE_URL $TILE_NAME $TILE_BBOX

md5sum "$TILE_NAME.versatiles" | awk '{ print $1 }' > "$TILE_NAME.versatiles.md5"
sha256sum "$TILE_NAME.versatiles" | awk '{ print $1 }' > "$TILE_NAME.versatiles.sha256"
lftp ftp://download-versatiles-org@storage.bunnycdn.com:21 -e "mput $TILE_NAME.*; exit"
