#!/bin/bash
# ncurses — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "ncurses-6.5-20250809"
tar -xf "ncurses-6.5-20250809.tgz"
pushd "ncurses-6.5-20250809" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/ncurses.html

mkdir build
pushd build
  ../configure --prefix=$LFS/tools AWK=gawk
  make -C include
  make -C progs tic
  install progs/tic $LFS/tools/bin
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

make

make DESTDIR=$LFS install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h


popd >/dev/null
