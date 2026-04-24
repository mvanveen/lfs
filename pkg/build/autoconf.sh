# autoconf  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/autoconf.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf autoconf-2.72
tar xf autoconf-2.72.tar.xz
cd autoconf-2.72

./configure --prefix=/usr

make

make check

make install

cd /mnt/lfs/sources
rm -rf autoconf-2.72
