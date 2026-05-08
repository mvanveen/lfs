#!/bin/bash
# Create a partitioned loop-backed disk image and mount an ext4 root at $LFS.
# LFS 12.4 §2.4 - Creating a file system on the partition.
set -euxo pipefail

IMG=${IMG:-/lfs.img}
SIZE_GB=${SIZE_GB:-30}
LFS=${LFS:-/mnt/lfs}

# Allocate a sparse image and create a single Linux partition.
truncate -s "${SIZE_GB}G" "$IMG"
parted -s "$IMG" mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on

# Map partitions to /dev/mapper/loopNpM.
MAP_OUT=$(kpartx -av "$IMG")
echo "$MAP_OUT"
LOOPPART=$(echo "$MAP_OUT" | awk '/^add/ {print $3; exit}')
test -n "$LOOPPART"

mkfs.ext4 -F "/dev/mapper/$LOOPPART"

mkdir -pv "$LFS"
mount -v -t ext4 "/dev/mapper/$LOOPPART" "$LFS"

# Persist for later stages.
echo "export LFS=$LFS" > /etc/profile.d/lfs.sh
echo "export LOOPPART=$LOOPPART"  >> /etc/profile.d/lfs.sh
