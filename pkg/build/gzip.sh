#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf gzip-1.10
tar xf gzip-1.10.tar.xz
cd gzip-1.10

./configure \
    --prefix=/tools

make

make DESTDIR=$LFS install
