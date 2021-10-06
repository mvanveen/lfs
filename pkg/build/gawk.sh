#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf gawk-5.1.0
tar xf gawk-5.1.0.tar.xz
cd gawk-5.1.0

sed -i 's/extras//' Makefile.in

./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(./config.guess)

make

#make check

make DESTDIR=$LFS install

#mkdir -v /usr/share/doc/gawk-5.0.1
#cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.0.1
