cd /mnt/lfs/sources

rm -rf xf glibc-2.31
tar xf glibc-2.31.tar.xz
cd glibc-2.31

mkdir -v build
cd build

../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include      \
      libc_cv_ctors_header=yes

make -j1

make install
