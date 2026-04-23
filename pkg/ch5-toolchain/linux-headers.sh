#!/bin/bash
# linux-headers — from ch5-toolchain
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "linux-6.16.1"
tar -xf "linux-6.16.1.tar.xz"
pushd "linux-6.16.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr


popd >/dev/null
