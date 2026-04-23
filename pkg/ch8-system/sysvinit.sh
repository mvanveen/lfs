#!/bin/bash
# sysvinit — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "sysvinit-3.14"
tar -xf "sysvinit-3.14.tar.xz"
pushd "sysvinit-3.14" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sysvinit.html

patch -Np1 -i ../sysvinit-3.14-consolidated-1.patch

make

make install


popd >/dev/null
