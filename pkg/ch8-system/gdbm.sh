#!/bin/bash
# gdbm — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gdbm-1.26"
tar -xf "gdbm-1.26.tar.gz"
pushd "gdbm-1.26" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gdbm.html

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

make check

make install


popd >/dev/null
