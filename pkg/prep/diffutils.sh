# diffutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/diffutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf diffutils-3.12
tar xf diffutils-3.12.tar.xz
cd diffutils-3.12

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            gl_cv_func_strcasecmp_works=y \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf diffutils-3.12
