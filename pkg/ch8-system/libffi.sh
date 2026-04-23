#!/bin/bash
# libffi — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "libffi-3.5.2"
tar -xf "libffi-3.5.2.tar.gz"
pushd "libffi-3.5.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libffi.html

./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native

make

make check

make install


popd >/dev/null
