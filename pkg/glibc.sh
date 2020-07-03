cd /mnt/lfs/sources

rm -rf xf glibc-2.31
tar xf glibc-2.31.tar.xz
cd glibc-2.31

mkdir -v build
cd build

mkdir tmp/

../configure                             \
      TMP_DIR=tmp/                       \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include

make -j1

make install
