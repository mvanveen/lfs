#!/bin/bash
# patch — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "patch-2.8"
tar -xf "patch-2.8.tar.xz"
pushd "patch-2.8" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/patch.html

./configure --prefix=/usr

make

make check

make install


popd >/dev/null
