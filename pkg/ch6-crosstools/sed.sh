#!/bin/bash
# sed — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "sed-4.9"
tar -xf "sed-4.9.tar.xz"
pushd "sed-4.9" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/sed.html

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
