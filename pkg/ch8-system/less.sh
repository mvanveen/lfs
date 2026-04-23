#!/bin/bash
# less — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "less-679"
tar -xf "less-679.tar.gz"
pushd "less-679" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/less.html

./configure --prefix=/usr --sysconfdir=/etc

make

make check

make install


popd >/dev/null
