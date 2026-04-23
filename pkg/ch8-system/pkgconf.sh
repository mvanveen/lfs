#!/bin/bash
# pkgconf — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "pkgconf-2.5.1"
tar -xf "pkgconf-2.5.1.tar.xz"
pushd "pkgconf-2.5.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/pkgconf.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

make

make install

ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1


popd >/dev/null
