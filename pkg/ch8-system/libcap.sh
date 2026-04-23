#!/bin/bash
# libcap — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "libcap-2.76"
tar -xf "libcap-2.76.tar.xz"
pushd "libcap-2.76" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libcap.html

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

make test

make prefix=/usr lib=lib install


popd >/dev/null
