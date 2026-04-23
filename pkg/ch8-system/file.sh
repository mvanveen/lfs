#!/bin/bash
# file — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "file-5.46"
tar -xf "file-5.46.tar.gz"
pushd "file-5.46" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/file.html

./configure --prefix=/usr

make

make check

make install


popd >/dev/null
