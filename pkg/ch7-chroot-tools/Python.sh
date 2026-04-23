#!/bin/bash
# Python — from ch7-chroot-tools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "Python-3.13.7"
tar -xf "Python-3.13.7.tar.xz"
pushd "Python-3.13.7" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/Python.html

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

make

make install


popd >/dev/null
