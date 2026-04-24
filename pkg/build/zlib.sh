# zlib  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zlib.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf zlib-1.3.1
tar xf zlib-1.3.1.tar.gz
cd zlib-1.3.1

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libz.a

cd /mnt/lfs/sources
rm -rf zlib-1.3.1
