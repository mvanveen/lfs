#!/bin/bash
# expat — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "expat-2.7.1"
tar -xf "expat-2.7.1.tar.xz"
pushd "expat-2.7.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/expat.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.1

make

make check

make install

install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.1


popd >/dev/null
