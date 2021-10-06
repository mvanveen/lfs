#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

#TODO: don't hardcode versions
rm -rf gcc-11.2.0
tar xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd build

mkdir -pv $LFS_TGT/libgcc
ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h

../configure \
    --build=$(../config.guess)  \
    --host=$LFS_TGT             \
    --prefix=/usr               \
    CC_FOR_TARGET=$LFS_TGT-gcc  \
    --with-build-sysroot=$LFS   \
    --enable-initfini-array     \
    --disable-nls                           \
    --disable-multilib                      \
    --disable-decimal-float                 \
    --disable-libatomic                     \
    --disable-libgomp                       \
    --disable-libquadmath                   \
    --disable-libssp                        \
    --disable-libvtv                        \
    --disable-libstdcxx                     \
    --enable-languages=c,c++

make -j $NUM_PROCS

make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc
