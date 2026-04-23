#!/bin/bash
# kmod — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "kmod-34.2"
tar -xf "kmod-34.2.tar.xz"
pushd "kmod-34.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kmod.html

mkdir -p build
cd       build

meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false

ninja

ninja install


popd >/dev/null
