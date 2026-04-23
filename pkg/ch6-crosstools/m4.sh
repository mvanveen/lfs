#!/bin/bash
# m4 — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "m4-1.4.20"
tar -xf "m4-1.4.20.tar.xz"
pushd "m4-1.4.20" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/m4.html

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
