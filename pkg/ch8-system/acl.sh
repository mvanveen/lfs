#!/bin/bash
# acl — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "acl-2.3.2"
tar -xf "acl-2.3.2.tar.xz"
pushd "acl-2.3.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/acl.html

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2

make

make check

make install


popd >/dev/null
