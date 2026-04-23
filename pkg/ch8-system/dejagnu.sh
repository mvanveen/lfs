#!/bin/bash
# dejagnu — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "dejagnu-1.6.3"
tar -xf "dejagnu-1.6.3.tar.gz"
pushd "dejagnu-1.6.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/dejagnu.html

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

make check

make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3


popd >/dev/null
