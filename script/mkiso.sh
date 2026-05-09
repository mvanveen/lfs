#!/bin/bash
# Build a hybrid ISO from the LFS rootfs.
# Resolves Fossil ticket ea4402591f (partial): the ISO produces a
# BIOS-bootable / UEFI-bootable hybrid CD that GRUB can launch the LFS
# kernel from.  This script is the "kernel + grub.cfg only" smoke version
# -- a follow-up will add a real initramfs / live rootfs so the ISO is
# end-to-end bootable into a usable system.
#
# Run inside the LFS chroot.  Output: $OUT (default /boot/lfs.iso).

set -euo pipefail

OUT=${OUT:-/boot/lfs.iso}
KVER=${KVER:-6.16.1-lfs-12.4}
WORK=${WORK:-/tmp/lfs-iso-$$}
PATH="/usr/local/sbin:/usr/local/bin:$PATH"

# Sanity: xorriso is not in LFS base; we install it from BLFS source into
# /usr/local/bin via script/build-xorriso.sh below.
if ! command -v xorriso >/dev/null; then
    echo "xorriso missing -- run: bash /root/build-xorriso.sh first" >&2
    exit 1
fi

trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK"/boot/grub

cp -v "/boot/vmlinuz-${KVER}" "$WORK/boot/vmlinuz-${KVER}"

cat > "$WORK/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=5
set gfxpayload=text

menuentry "LFS 12.4 (kernel boot, no root)" {
    linux /boot/vmlinuz-${KVER} console=ttyS0,115200 init=/bin/sh
}
EOF

grub-mkrescue --output="$OUT" "$WORK"
ls -la "$OUT"
file "$OUT"
