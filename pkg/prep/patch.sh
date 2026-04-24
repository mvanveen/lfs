# patch  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf patch-2.8
tar xf patch-2.8.tar.xz
cd patch-2.8

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf patch-2.8
