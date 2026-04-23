#!/bin/bash
# gettext — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gettext-0.26"
tar -xf "gettext-0.26.tar.xz"
pushd "gettext-0.26" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gettext.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.26

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so


popd >/dev/null
