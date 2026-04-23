# gzip  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gzip-1.14
tar xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf gzip-1.14
