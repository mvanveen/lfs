#!/bin/bash
# gzip — from ch6-crosstools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gzip-1.14"
tar -xf "gzip-1.14.tar.xz"
pushd "gzip-1.14" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install


popd >/dev/null
