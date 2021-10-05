cd /mnt/lfs/sources;

rm -rf binutils-2.37;
tar xf binutils-2.37.tar.xz
cd binutils-2.37

patch -Np1 -i ../binutils-2.37-upstream_fix-1.patch

expect -c "spawn ls"

sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in

mkdir -v build

chown -R lfs .
chmod -R 777 .

cd       build

su lfs -c "../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --disable-werror"

su lfs -c "make -j $NUM_PROCS"
su lfs -c "make -j1 install"
