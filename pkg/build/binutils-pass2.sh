#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources;

rm -rf binutils-2.37
tar xf binutils-2.37.tar.xz
cd binutils-2.37

mkdir -v build
cd build

../configure \
    --prefix=/usr \
    --build=$(../config.guess) \
    --host=$LFS_TGT  \
    --disable-nls    \
    --enable-shared  \
    --disable-werror \
    --enable-64-bit-bfd

make

make DESTDIR=$LFS install -j1

install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
