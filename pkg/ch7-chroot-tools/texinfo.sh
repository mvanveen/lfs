#!/bin/bash
# texinfo — from ch7-chroot-tools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "texinfo-7.2"
tar -xf "texinfo-7.2.tar.xz"
pushd "texinfo-7.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/texinfo.html

./configure --prefix=/usr

make

make install


popd >/dev/null
