#!/bin/bash

set -eu
set -x

if [ ! -d tmp ]; then
  mkdir tmp
fi
pushd tmp

exec < ../urls.txt
while read url
do
  downloadname=$(basename $url)
  noext=$(basename $downloadname .zip)
  curl -Lsk $url -o "$downloadname"
  if [ -f $downloadname ]; then
    unzip -u $downloadname
    ogr2ogr -f GeoJSON -t_srs urn:ogc:def:crs:OGC:1.3:CRS84 $noext.geojson $noext.shp
    node ../node_modules/topojson/bin/topojson $noext.geojson -p -- > $noext.topojson
  fi
done

popd
mv tmp/PLSS*json data/plss/ || true
mv tmp/Lakes*json data/hydrography/ || true
mv tmp/Streams*json data/hydrography/ || true

# move remaining to administration
mv tmp/*json data/administration/ || true
