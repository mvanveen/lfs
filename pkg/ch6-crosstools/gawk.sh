#!/bin/bash
# gawk — from ch6-crosstools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gawk-5.3.2"
tar -xf "gawk-5.3.2.tar.xz"
pushd "gawk-5.3.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gawk.html

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install


popd >/dev/null
