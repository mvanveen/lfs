#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf grep-3.7
tar xf grep-3.7.tar.xz
cd grep-3.7

./configure \
    --prefix=/usr \
    --host=$LFS_TGT

make

#make check

make DESTDIR=$LFS install
