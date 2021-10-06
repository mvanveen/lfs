#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf sed-4.8
tar xf sed-4.8.tar.xz
cd sed-4.8

./configure \
    --prefix=/usr \
    --host=$LFS_TGT

make

make DESTDIR=$LFS install
