#!/bin/bash
# texinfo — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "texinfo-7.2"
tar -xf "texinfo-7.2.tar.xz"
pushd "texinfo-7.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/texinfo.html

sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm

./configure --prefix=/usr

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd


popd >/dev/null
