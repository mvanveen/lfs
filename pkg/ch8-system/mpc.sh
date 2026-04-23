#!/bin/bash
# mpc — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "mpc-1.3.1"
tar -xf "mpc-1.3.1.tar.gz"
pushd "mpc-1.3.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpc.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

make check

make install
make install-html


popd >/dev/null
