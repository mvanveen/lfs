#!/bin/bash
# m4 — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "m4-1.4.20"
tar -xf "m4-1.4.20.tar.xz"
pushd "m4-1.4.20" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/m4.html

./configure --prefix=/usr

make

make check

make install


popd >/dev/null
