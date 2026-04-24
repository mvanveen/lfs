# xz  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xz.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf xz-5.8.1
tar xf xz-5.8.1.tar.xz
cd xz-5.8.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.1

make

make check

make install

cd /mnt/lfs/sources
rm -rf xz-5.8.1
