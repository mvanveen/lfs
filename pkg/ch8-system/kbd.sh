#!/bin/bash
# kbd — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "kbd-2.8.0"
tar -xf "kbd-2.8.0.tar.xz"
pushd "kbd-2.8.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kbd.html

patch -Np1 -i ../kbd-2.8.0-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make

make install

cp -R -v docs/doc -T /usr/share/doc/kbd-2.8.0


popd >/dev/null
