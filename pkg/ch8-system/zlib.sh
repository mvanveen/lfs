#!/bin/bash
# zlib — from ch8-system
# See source URL at top of command list below.
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
