#!/bin/bash
# diffutils — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "diffutils-3.12"
tar -xf "diffutils-3.12.tar.xz"
pushd "diffutils-3.12" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/diffutils.html

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
