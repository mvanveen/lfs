#!/bin/bash
# flex — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "flex-2.6.4"
tar -xf "flex-2.6.4.tar.gz"
pushd "flex-2.6.4" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/flex.html

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

make check

make install

ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1


popd >/dev/null
