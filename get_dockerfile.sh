#!/bin/bash

set -eE

if [[ ! "$#" =~ ^(1|2) ]] ; then
    echo "Usage: $(basename "$0") <docker-image-name> [<output-docker-file>]"
    exit 1
fi
tmpdir=""

trap 'rm -rf "$tmpdir"' EXIT

image="$1"
outfile="$2"
dockerfile="$outfile"
tmpdir="$(mktemp -d)"
inspect="$tmpdir"/inspect.json

[ "$outfile" == "" ] && dockerfile="$tmdir"/dockerfile.tmp

docker inspect "$image" > "$inspect"
/root/rapidfort/common/rf_make_dockerfiles.py localhost 1234 "$inspect" docker "$dockerfile" /dev/null

if [ "$outfile" == "" ] ; then
    cat "$dockerfile"
else
    echo "Dockerfile $outfile generated."
fi

rm -rf "$tmpdir"
