#!/bin/bash
# patch — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
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
