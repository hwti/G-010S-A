#!/bin/sh

set -e

IMAGE="$1"

if [ -z "$IMAGE" ] || [ ! -e "$IMAGE" ]
then
    echo "Usage : $0 image"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]
then
    echo "Not running as root, using fakeroot"
    exec fakeroot "$0" "$IMAGE"
fi

./extract.sh "$IMAGE"

DIR="${IMAGE%.*}"
ROOTFS="$DIR/squashfs-root"
ROOTFS_ABS="$PWD/$ROOTFS"

printf "\nPatching rootfs ...\n"
for PATCH_DIR in patches/*
do
    echo " - $PATCH_DIR :"
    cd "$PATCH_DIR" && { ./patch.sh "$ROOTFS_ABS"; cd ../..; }
done

printf "\nCreating new squashfs image\n"
mksquashfs "$ROOTFS" patched.squashfs -noappend -comp xz -b 262144

OUT="${IMAGE%.*}_patched.bin"
cat "$DIR/uImage" patched.squashfs > "$OUT"
dd if=/dev/null of="$OUT" bs=1 seek=6291456
printf "\n%s created successfully\n" "$OUT"

rm patched.squashfs
