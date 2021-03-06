#!/bin/bash
# Обновление данных в PostGIS по блоку скачиваемых данных
cd $(dirname "$0");
bbox="$1";
pwd;
apiadr="http://overpass-api.de/api/interpreter?data=[out:xml];(++node($bbox);++%3C;);out+meta;";
s=$(date '+%s');
f="$2 $s";
#wget "$apiadr" -O - -o /dev/null > "$f.osm";
wget "$apiadr" -O "$f.osm";
osmium export --no-progress --config='osmium.conf' -f pg "$f.osm" -o "$f.pg" && echo "osmium ✔";
echo "PostGIS geom: "$(wc -l "$f.pg");
echo "truncate table \"public\".\"OSM $2\";" | psql -e -d "$3";
echo "\\copy \"public\".\"OSM $2\" FROM '$f.pg';" | psql -e -d "$3";
r=$?;
echo " refresh materialized view \"$2\".\"∀\";" | psql -e -d "$3";
if [ $r == 0 ]; then
  echo "postgis ✔";
  xz -z -9 "$f.osm";
  # rm -v "$f.osm";
  rm -v "$f.pg";
fi;
