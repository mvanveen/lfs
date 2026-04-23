# gzip  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gzip.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gzip-1.14
tar xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr

make

make check

make install

cd /mnt/lfs/sources
rm -rf gzip-1.14
