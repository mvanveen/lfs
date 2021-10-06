#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf xz-5.2.5;
tar xf xz-5.2.5.tar.xz
cd xz-5.2.5

./configure \
    --prefix=/usr    \
    --target=$LFS_TGT \
    --build=$(build-aux/config.guess) \
    --disable-static \
    --docdir=/usr/share/doc/xz-5.2.5

make

make check

make DESTDIR=$LFS install
