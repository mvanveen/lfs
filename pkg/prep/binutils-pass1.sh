# binutils-pass1  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf binutils-2.45
tar xf binutils-2.45.tar.xz
cd binutils-2.45

mkdir -v build
cd       build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags  \
             --enable-default-hash-style=gnu

make

make install

cd /mnt/lfs/sources
rm -rf binutils-2.45
