# libffi  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libffi.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf libffi-3.5.2
tar xf libffi-3.5.2.tar.gz
cd libffi-3.5.2

./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native

make

make check

make install

cd /mnt/lfs/sources
rm -rf libffi-3.5.2
