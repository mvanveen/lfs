#!/bin/bash
# patch — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "patch-2.8"
tar -xf "patch-2.8.tar.xz"
pushd "patch-2.8" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
