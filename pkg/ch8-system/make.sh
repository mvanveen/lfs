#!/bin/bash
# make — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "make-4.4.1"
tar -xf "make-4.4.1.tar.gz"
pushd "make-4.4.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/make.html

./configure --prefix=/usr

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install


popd >/dev/null
