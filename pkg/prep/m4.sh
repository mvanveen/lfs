# m4  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/m4.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf m4-1.4.20
tar xf m4-1.4.20.tar.xz
cd m4-1.4.20

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf m4-1.4.20
