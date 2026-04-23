#!/bin/bash
# gmp — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gmp-6.3.0"
tar -xf "gmp-6.3.0.tar.xz"
pushd "gmp-6.3.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gmp.html

ABI=32 ./configure ...

sed -i '/long long t1;/,+1s/()/(...)/' configure

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html


popd >/dev/null
