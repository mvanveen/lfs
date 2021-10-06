#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf tar-1.34
tar xf tar-1.34.tar.xz
cd tar-1.34

./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install
