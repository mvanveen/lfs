#!/bin/bash
# psmisc — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "psmisc-23.7"
tar -xf "psmisc-23.7.tar.xz"
pushd "psmisc-23.7" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/psmisc.html

./configure --prefix=/usr

make

make check

make install


popd >/dev/null
