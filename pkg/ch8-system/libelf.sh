#!/bin/bash
# libelf — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "elfutils-0.193"
tar -xf "elfutils-0.193.tar.bz2"
pushd "elfutils-0.193" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libelf.html

./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a


popd >/dev/null
