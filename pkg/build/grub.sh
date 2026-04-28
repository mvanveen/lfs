# grub  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/grub.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf grub-2.12
tar xf grub-2.12.tar.xz
cd grub-2.12

unset {C,CPP,CXX,LD}FLAGS

echo depends bli part_gpt > grub-core/extra_deps.lst

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-efiemu  \
            --disable-werror

make

make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd /sources
rm -rf grub-2.12
