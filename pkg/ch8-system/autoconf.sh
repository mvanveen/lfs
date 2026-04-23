#!/bin/bash
# autoconf — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "autoconf-2.72"
tar -xf "autoconf-2.72.tar.xz"
pushd "autoconf-2.72" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/autoconf.html

./configure --prefix=/usr

make

make check

make install


popd >/dev/null
