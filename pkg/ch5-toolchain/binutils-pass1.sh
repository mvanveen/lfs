#!/bin/bash
# binutils-pass1 — from ch5-toolchain
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "binutils-2.45"
tar -xf "binutils-2.45.tar.xz"
pushd "binutils-2.45" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html

mkdir -v build
cd       build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make

make install


popd >/dev/null
