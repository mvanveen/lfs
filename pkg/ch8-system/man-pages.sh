#!/bin/bash
# man-pages — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "man-pages-6.15"
tar -xf "man-pages-6.15.tar.xz"
pushd "man-pages-6.15" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-pages.html

rm -v man3/crypt*

make -R GIT=false prefix=/usr install


popd >/dev/null
