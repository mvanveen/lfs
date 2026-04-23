#!/bin/bash
# bison — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "bison-3.8.2"
tar -xf "bison-3.8.2.tar.xz"
pushd "bison-3.8.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bison.html

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

make

make check

make install


popd >/dev/null
