#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf patch-2.7.6
tar xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(biuld-aux/config.guess)

make

#make check

make DESTDIR=$LFS install
