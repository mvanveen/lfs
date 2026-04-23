#!/bin/bash
# man-db — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "man-db-2.13.1"
tar -xf "man-db-2.13.1.tar.xz"
pushd "man-db-2.13.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-db.html

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=

make

make check

make install


popd >/dev/null
