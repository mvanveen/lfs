#!/bin/bash
# file — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "file-5.46"
tar -xf "file-5.46.tar.gz"
pushd "file-5.46" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la


popd >/dev/null
