#!/bin/bash
# grep — from ch6-crosstools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "grep-3.12"
tar -xf "grep-3.12.tar.xz"
pushd "grep-3.12" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/grep.html

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
