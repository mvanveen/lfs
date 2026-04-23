# xz  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/xz.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf xz-5.8.1
tar xf xz-5.8.1.tar.xz
cd xz-5.8.1

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.8.1

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd /mnt/lfs/sources
rm -rf xz-5.8.1
