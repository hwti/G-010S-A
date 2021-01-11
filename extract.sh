#!/bin/sh

set -e

if [ -z "$1" ]
then
    echo "Usage : $0 image(s)"
    exit 1
fi

while :
do
    [ -z "$1" ] && exit 0

    IMAGE="$1"
    echo "Extracting $IMAGE ..."

    KERNEL_SIZE=$((0x$(od -j12 -N4 -tx1 -An "$IMAGE" | tr -d ' ')))

    DIR="${IMAGE%.*}"
    mkdir -p "$DIR"

    head -c $((64 + KERNEL_SIZE)) "$IMAGE" > "$DIR/uImage"
    echo "Extracted $DIR/uImage"

    tail -c +65 "$DIR/uImage" > "$DIR/kernel.lzma"
    echo "Extracted $DIR/kernel.lzma"

    tail -c +$((65 + KERNEL_SIZE)) "$IMAGE" > "$DIR/rootfs.squashfs"
    echo "Extracted $DIR/rootfs.squashfs"

    rm -rf "$DIR/squashfs-root"
    if unsquashfs -n -d "$DIR/squashfs-root" "$DIR/rootfs.squashfs" > /dev/null
    then
        echo "Extracted rootfs in $DIR/squashfs-root"
    else
        if [ "$(id -u)" -ne 0 ]
        then
            echo "Errors during rootfs extraction, ignored since not running as root"
        else
            echo "Failed to extract rootfs"
            exit 1
        fi
    fi

    shift
done
