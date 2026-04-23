#!/bin/bash
# attr — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "attr-2.5.2"
tar -xf "attr-2.5.2.tar.gz"
pushd "attr-2.5.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/attr.html

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make

make check

make install


popd >/dev/null
