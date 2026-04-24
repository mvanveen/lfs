# libelf  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libelf.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf elfutils-0.193
tar xf elfutils-0.193.tar.bz2
cd elfutils-0.193

./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /mnt/lfs/sources
rm -rf elfutils-0.193
