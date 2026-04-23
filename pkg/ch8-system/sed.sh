#!/bin/bash
# sed — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "sed-4.9"
tar -xf "sed-4.9.tar.xz"
pushd "sed-4.9" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sed.html

./configure --prefix=/usr

make
make html

chown -R tester .
su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9


popd >/dev/null
