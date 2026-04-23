#!/bin/bash
# bc — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "bc-7.0.3"
tar -xf "bc-7.0.3.tar.xz"
pushd "bc-7.0.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bc.html

CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

make

make test

make install


popd >/dev/null
