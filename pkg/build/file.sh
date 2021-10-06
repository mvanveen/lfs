#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf file-5.38
tar xzf file-5.38.tar.gz
cd file-5.38

mkdir build

pushd build
    ../configure \
	--disable-bzlib \
	--disable-libseccomp \
	--disable-xzlib \
	--disable-zlib
    make
popd


./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file

#make check

make DESTDIR=$LFS install
