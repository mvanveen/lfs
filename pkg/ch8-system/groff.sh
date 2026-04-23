#!/bin/bash
# groff — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "groff-1.23.0"
tar -xf "groff-1.23.0.tar.gz"
pushd "groff-1.23.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/groff.html

PAGE=<paper_size> ./configure --prefix=/usr

make

make check

make install


popd >/dev/null
