#!/bin/bash
# lz4 — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "lz4-1.10.0"
tar -xf "lz4-1.10.0.tar.gz"
pushd "lz4-1.10.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/lz4.html

make BUILD_STATIC=no PREFIX=/usr

make -j1 check

make BUILD_STATIC=no PREFIX=/usr install


popd >/dev/null
