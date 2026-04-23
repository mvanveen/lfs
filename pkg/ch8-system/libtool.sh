#!/bin/bash
# libtool — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "libtool-2.5.4"
tar -xf "libtool-2.5.4.tar.xz"
pushd "libtool-2.5.4" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libtool.html

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libltdl.a


popd >/dev/null
