#!/bin/bash
# tar — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "tar-1.35"
tar -xf "tar-1.35.tar.xz"
pushd "tar-1.35" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/tar.html

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35


popd >/dev/null
