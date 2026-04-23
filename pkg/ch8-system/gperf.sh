#!/bin/bash
# gperf — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gperf-3.3"
tar -xf "gperf-3.3.tar.gz"
pushd "gperf-3.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gperf.html

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3

make

make check

make install


popd >/dev/null
