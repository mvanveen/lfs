#!/bin/bash
# Python — from ch7-chroot-tools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
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
