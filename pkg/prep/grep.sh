# grep  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/grep.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf grep-3.12
tar xf grep-3.12.tar.xz
cd grep-3.12

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf grep-3.12
