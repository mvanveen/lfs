#!/bin/bash
# Materialize /srv/sources as its own filesystem.
#
# Resolves Fossil ticket 6b655786ce. Earlier versions of this layer kept
# /srv/sources as a directory on / (root), which means you can't resize,
# snapshot, or remount-read-only the source archive without touching the
# whole rootfs. This script:
#
#   1. creates a sparse ext4 image at $IMG (default /srv/sources.img)
#   2. mkfs.ext4 -t ext4 -L sources
#   3. moves the live /srv/sources contents into the new filesystem
#   4. mounts it at /srv/sources
#   5. adds the fstab entry so it auto-mounts on boot
#
# Idempotent: if $IMG already exists and /srv/sources is already a
# mountpoint backed by it, this is a no-op.
#
# Run inside the LFS chroot (or on the booted system). Requires the
# kernel CONFIG_BLK_DEV_LOOP=y (LFS default kernel config has it).

set -euo pipefail

IMG=${IMG:-/srv/sources.img}
SRV=${SRV:-/srv/sources}
SIZE=${SIZE:-8G}
LABEL=${LABEL:-sources}

if mountpoint -q "$SRV"; then
    case "$(findmnt -no SOURCE "$SRV" 2>/dev/null || true)" in
      *"$IMG"|*"$LABEL"*)  echo "$SRV already mounted from $IMG"; exit 0 ;;
    esac
fi

if [ ! -f "$IMG" ]; then
    echo "==> creating sparse $IMG ($SIZE)"
    truncate -s "$SIZE" "$IMG"
    mkfs.ext4 -q -L "$LABEL" -F "$IMG"
fi

# Migration: rsync the existing tree off, mount, rsync back.
TMPMNT=$(mktemp -d)
mount -o loop "$IMG" "$TMPMNT"

if [ -d "$SRV" ] && ! mountpoint -q "$SRV"; then
    if [ -n "$(ls -A "$SRV" 2>/dev/null)" ]; then
        echo "==> migrating $SRV -> $IMG (one-time)"
        # cp -a (archive) keeps perms+times+symlinks; faster than rsync
        # for one-shot migration and doesn't require rsync in the LFS
        # base toolchain.
        ( cd "$SRV" && tar cf - . ) | ( cd "$TMPMNT" && tar xf - )
        # Empty the now-stale directory under root so the mount sees nothing.
        rm -rf "${SRV:?}"/* "${SRV:?}"/.[!.]* 2>/dev/null || true
    fi
fi

mkdir -p "$SRV"
umount "$TMPMNT"
rmdir "$TMPMNT"
mount -o loop "$IMG" "$SRV"

# fstab entry, idempotent.
if ! grep -qE "^[^#].*[[:space:]]${SRV}[[:space:]]" /etc/fstab 2>/dev/null; then
    echo "==> writing /etc/fstab entry"
    cat >> /etc/fstab <<EOF

# /srv/sources -- per Fossil ticket 6b655786ce
$IMG          $SRV          ext4    loop,defaults,noatime,nodev,nosuid  0 2
EOF
fi

echo "==> done."
df -h "$SRV" | tail -1
