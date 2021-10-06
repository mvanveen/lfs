#!/usr/bin/env bash

source /home/lfs/.bashrc

set -xe

cd /mnt/lfs/sources;

rm -rf ncurses-6.2
tar xzf ncurses-6.2.tar.gz
cd ncurses-6.2

#sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
sed -i s/mawk// configure

mkdir build
pushd build

  ../configure
  make -C include
  make -C progs tic
popd

./configure \
    --prefix=/usr           \
    --host=$LFS_TGT \
    --build=$(./config.guess) \
    --mandir=/usr/share/man \
    --with-manpage-format=normal \
    --with-shared           \
    --without-debug         \
    --without-ada           \
    --without-normal        \
    --enable-widec

make

make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
#mv -v /usr/lib/libncursesw.so.6* /lib
#
#ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
#
#for lib in ncurses form panel menu ; do
#    rm -vf                    /usr/lib/lib${lib}.so
#    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
#    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
#done
#
#rm -vf                     /usr/lib/libcursesw.so
#echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
#ln -sfv libncurses.so      /usr/lib/libcurses.so
#
#mkdir -v       /usr/share/doc/ncurses-6.2
#cp -v -R doc/* /usr/share/doc/ncurses-6.2
