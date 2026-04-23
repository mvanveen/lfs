#!/bin/bash
# bc — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
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
