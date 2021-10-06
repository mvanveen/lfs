#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf diffutils-3.8
tar xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr --host=$LFS_TGT

make

#make check

make DESTDIR=$LFS install
