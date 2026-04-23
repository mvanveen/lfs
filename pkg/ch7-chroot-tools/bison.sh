#!/bin/bash
# bison — from ch7-chroot-tools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "bison-3.8.2"
tar -xf "bison-3.8.2.tar.xz"
pushd "bison-3.8.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/bison.html

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make

make install


popd >/dev/null
