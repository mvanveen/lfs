#!/bin/bash
# intltool — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "intltool-0.51.0"
tar -xf "intltool-0.51.0.tar.gz"
pushd "intltool-0.51.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/intltool.html

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO


popd >/dev/null
