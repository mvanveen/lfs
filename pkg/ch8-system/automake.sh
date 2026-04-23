#!/bin/bash
# automake — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "automake-1.18.1"
tar -xf "automake-1.18.1.tar.xz"
pushd "automake-1.18.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/automake.html

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1

make

make -j$(($(nproc)>4?$(nproc):4)) check

make install


popd >/dev/null
