cd /mnt/lfs/sources

rm -rf xf glibc-2.31
tar xf glibc-2.31.tar.xz
cd glibc-2.31

mkdir -v build
cd build

mkdir -p tmp

../configure                             \
      TMPDIR='tmp'                      \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes           \
      libc_cv_c_cleanup=yes
      #libc_cv_ctors_header=yes

make -j1

make install

echo 'int main() {}' > dummy.c;
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
