# tar  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/tar.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf tar-1.35
tar xf tar-1.35.tar.xz
cd tar-1.35

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf tar-1.35
