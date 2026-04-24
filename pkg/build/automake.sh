# automake  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/automake.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf automake-1.18.1
tar xf automake-1.18.1.tar.xz
cd automake-1.18.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1

make

make -j$(($(nproc)>4?$(nproc):4)) check

make install

cd /mnt/lfs/sources
rm -rf automake-1.18.1
