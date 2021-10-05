#!/usr/bin/env bash

source /home/lfs/.bashrc

set -xe

#TODO: don't hardcode version
cd /mnt/lfs/sources

rm -rf gcc-11.2.0
tar xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

patch -p1 < ../gcc-11.2.0.patch

mkdir -v build

cd build

../libstdc++-v3/configure \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

make |& tee /root/libstdcxx-pass1.log
make DESTDIR=$LFS install
