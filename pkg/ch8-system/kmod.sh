#!/bin/bash
# kmod — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
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
