#!/bin/bash
# findutils — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "findutils-4.10.0"
tar -xf "findutils-4.10.0.tar.xz"
pushd "findutils-4.10.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/findutils.html

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install


popd >/dev/null
