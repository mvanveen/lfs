#TODO: don't hardcode versions
cd /mnt/lfs/sources
rm -rf gcc-11.2.0
tar xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
#
#for file in gcc/config/{linux,i386/linux{,64}}.h
#do
#  cp -uv $file{,.orig}
#  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
#      -e 's@/usr@/tools@g' $file.orig > $file
#  echo '
##undef STANDARD_STARTFILE_PREFIX_1
##undef STANDARD_STARTFILE_PREFIX_2
##define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
##define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
#  touch $file.orig
#done
#
#sed -e '/static.*SIGSTKSZ/d' \
#    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
#    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd build

chmod -R 777 /mnt/lfs/sources/gcc-11.2.0
chown -R lfs /mnt/lfs/sources/gcc-11.2.0

su lfs -c "../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++"

su lfs -c "make -j $NUM_PROCS"

ulimit -s 32768

chown -Rv tester .
su tester -c "PATH=$PATH make -k check" | tee /var/log/gcc-pass-1-check.log

../contrib/test_summary
make install
