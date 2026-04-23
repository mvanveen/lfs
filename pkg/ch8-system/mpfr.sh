#!/bin/bash
# mpfr — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "mpfr-4.2.2"
tar -xf "mpfr-4.2.2.tar.xz"
pushd "mpfr-4.2.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpfr.html

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

make
make html

make check

make install
make install-html


popd >/dev/null
