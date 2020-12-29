#!/bin/sh

set -e

ROOTFS=$1

echo "Updating dropbear to 2020.81"
cp -f dropbear "$ROOTFS/usr/sbin/dropbear"

# Generate host keys as needed (so we must not have placeholders)
patch -p1 -d "$ROOTFS" < generate-host-keys-as-needed.patch
rm -f "$ROOTFS"/etc/dropbear/dropbear_*_host_key

# Make dropbear config (host keys, authorized_keys) persistent
echo "/etc/dropbear:/configs/etc/dropbear" >> "$ROOTFS/usr/cfg/etc.cfg"
