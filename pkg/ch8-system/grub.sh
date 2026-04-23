#!/bin/bash
# grub — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "grub-2.12"
tar -xf "grub-2.12.tar.xz"
pushd "grub-2.12" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/grub.html

unset {C,CPP,CXX,LD}FLAGS

echo depends bli part_gpt > grub-core/extra_deps.lst

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

make

make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions


popd >/dev/null
