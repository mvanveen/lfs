#!/bin/bash
# xz — from ch6-crosstools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "xz-5.8.1"
tar -xf "xz-5.8.1.tar.xz"
pushd "xz-5.8.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/xz.html

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.1

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la


popd >/dev/null
