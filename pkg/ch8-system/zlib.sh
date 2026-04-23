#!/bin/bash
# zlib — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "zlib-1.3.1"
tar -xf "zlib-1.3.1.tar.gz"
pushd "zlib-1.3.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zlib.html

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libz.a


popd >/dev/null
