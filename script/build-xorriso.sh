#!/bin/bash
# Build xorriso from upstream tarball into /usr/local; needed for grub-mkrescue.
# xorriso is not in LFS 12.4 base; pkgsrc/sysutils/libisoburn pulls in cmake
# transitively, so we compile from upstream directly to keep the ISO build
# path small.  Tarball lives at /srv/sources/blfs/xorriso-${VER}.tar.gz.
#
# Resolves part of Fossil ticket ea4402591f.

set -euo pipefail

VER=${VER:-1.5.6}
SRC=/srv/sources/blfs/xorriso-${VER}.tar.gz
WORK=/tmp/xorriso-build
URL=${URL:-https://www.gnu.org/software/xorriso/xorriso-${VER}.tar.gz}

if [ ! -f "$SRC" ]; then
    mkdir -p "$(dirname "$SRC")"
    echo "==> downloading xorriso-${VER}"
    curl -sL -o "$SRC" "$URL"
fi

# md5 check
EXPECTED=${EXPECTED_MD5:-0040565d12d15e81be90f0c90272aa82}
GOT=$(md5sum "$SRC" | awk '{print $1}')
if [ "$EXPECTED" != "$GOT" ]; then
    echo "md5 mismatch: $GOT (expected $EXPECTED)" >&2
    exit 1
fi

rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"
tar xf "$SRC"
cd "xorriso-${VER}"

./configure --prefix=/usr/local --disable-static
make -j"$(nproc)"
make install

/usr/local/bin/xorriso --version 2>&1 | head -2
