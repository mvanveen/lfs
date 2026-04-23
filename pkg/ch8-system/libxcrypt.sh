#!/bin/bash
# libxcrypt — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "libxcrypt-4.4.38"
tar -xf "libxcrypt-4.4.38.tar.xz"
pushd "libxcrypt-4.4.38" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libxcrypt.html

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

make

make check

make install

make distclean
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=glibc  \
            --disable-static             \
            --disable-failure-tokens
make
cp -av --remove-destination .libs/libcrypt.so.1* /usr/lib


popd >/dev/null
