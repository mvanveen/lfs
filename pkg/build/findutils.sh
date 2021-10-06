#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf findutils-4.8.0
tar xf findutils-4.8.0.tar.xz
cd findutils-4.8.0

./configure \
    --prefix=/usr \
    --localstatedir=/var/lib/locate \
    --host=$LFS_TGT \
    --build=$(buld-aux/config.guess)

make

#make check

make DESTDIR=$LFS install

#mv -v /usr/bin/find /bin
#sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
