#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf make-4.3
tar xzf make-4.3.tar.gz
cd make-4.3

./configure \
    --prefix=/usr \
    --without-guile \
    --host=$LFS_TGT \
    --build=$(build-aux/config.guess)

make

#make PERL5LIB=$PWD/tests/ check

make DESTDIR=$LFS install
