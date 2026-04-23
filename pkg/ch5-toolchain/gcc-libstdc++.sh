#!/bin/bash
# gcc-libstdc++ — from ch5-toolchain
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gcc-15.2.0"
tar -xf "gcc-15.2.0.tar.xz"
pushd "gcc-15.2.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-libstdc++.html

mkdir -v build
cd       build

../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la


popd >/dev/null
