# gcc-libstdc++  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-libstdc++.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gcc-15.2.0
tar xf gcc-15.2.0.tar.xz
cd gcc-15.2.0

mkdir -v build
cd       build

../libstdc++-v3/configure      \
    --host=$LFS_TGT            \
    --build=$(../config.guess) \
    --prefix=/usr              \
    --disable-multilib         \
    --disable-nls              \
    --disable-libstdcxx-pch    \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/15.2.0

make

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd /mnt/lfs/sources
rm -rf gcc-15.2.0
