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

    KERNEL_SIZE=$(($(od --skip-bytes=12 --read-bytes=4 --endian=big -t u4 -A n "$IMAGE")))

    DIR="${IMAGE%.*}"
    mkdir -p "$DIR"

    dd if="$IMAGE" of="$DIR/uImage" iflag='count_bytes' count=$((64 + KERNEL_SIZE)) status=none
    echo "Extracted $DIR/uImage"

    dd if="$IMAGE" of="$DIR/kernel.lzma" iflag='skip_bytes,count_bytes' skip=64 count=$KERNEL_SIZE status=none
    echo "Extracted $DIR/kernel.lzma"

    dd if="$IMAGE" of="$DIR/rootfs.squashfs" iflag='skip_bytes,count_bytes' skip=$((64 + KERNEL_SIZE)) status=none
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
