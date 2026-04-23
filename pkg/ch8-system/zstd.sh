#!/bin/bash
# zstd — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "zstd-1.5.7"
tar -xf "zstd-1.5.7.tar.gz"
pushd "zstd-1.5.7" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zstd.html

make prefix=/usr

make check

make prefix=/usr install

rm -v /usr/lib/libzstd.a


popd >/dev/null
