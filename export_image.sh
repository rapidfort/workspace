#!/bin/bash

set -eE

image="$1"
outdir="$2"

make_uuid()
{
    # Usage: make_uuid
    #
    # generate a UUID according to RFC 4122
    #

    local uuid

    #uuid_ref="$(cat /proc/sys/kernel/random/uuid)"         # a little slower and maybe perm issues?
    uuid="$(printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x" \
        $RANDOM $RANDOM \
        $RANDOM \
        $((RANDOM & 0x0fff | 0x4000)) \
        $((RANDOM & 0x3fff | 0x8000)) \
        $RANDOM $RANDOM $RANDOM)"
    echo -n "$uuid"
}

if [ "$#" != 2 ] ; then
    echo "Usage: $(basename "$0") <docker-image-name> <output-directory>"
    exit 1
fi

tmpdir="$(mktemp -d)"
mkdir -p "$outdir"

cont_name="export_image_temp_$(make_uuid)"

docker create --name "$cont_name" "$image" xxyyz > /dev/null
docker export "$cont_name" -o "$tmpdir"/export.tar
docker rm -f "$cont_name" > /dev/null 2>&1

tar -xpf "$tmpdir"/export.tar -C "$outdir"
rm -rf "$tmpdir"

echo "Image $image exported to $outdir."
