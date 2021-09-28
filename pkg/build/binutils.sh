cd /mnt/lfs/sources;

rm -rf binutils-2.37;
tar xf binutils-2.37.tar.xz
cd binutils-2.37

patch -Np1 -i ../binutils-2.37-upstream_fix-1.patch

expect -c "spawn ls"

sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in

mkdir -v build
cd       build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --disable-werror

#../configure --prefix=/usr       \
#             --enable-gold       \
#             --enable-ld=default \
#             --enable-plugins    \
#             --enable-shared     \
#             --disable-werror    \
#             --enable-64-bit-bfd \
#             --with-system-zlib
#make -j 1 tooldir=/usr
#
#make -k check
#
#make tooldir=/usr install

make -j $NUM_PROCS

make -j1 install
