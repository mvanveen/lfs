#!/bin/bash
# procps-ng — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "procps-ng-4.0.5"
tar -xf "procps-ng-4.0.5.tar.xz"
pushd "procps-ng-4.0.5" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/procps-ng.html

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install


popd >/dev/null
