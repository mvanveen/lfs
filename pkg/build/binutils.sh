# binutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/binutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf binutils-2.45
tar xf binutils-2.45.tar.xz
cd binutils-2.45

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make tooldir=/usr

make -k check

grep '^FAIL:' $(find -name '*.log')

make tooldir=/usr install

rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

cd /mnt/lfs/sources
rm -rf binutils-2.45
