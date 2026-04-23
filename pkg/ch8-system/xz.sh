#!/bin/bash
# xz — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "xz-5.8.1"
tar -xf "xz-5.8.1.tar.xz"
pushd "xz-5.8.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xz.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.1

make

make check

make install


popd >/dev/null
