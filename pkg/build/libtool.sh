# libtool  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libtool.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf libtool-2.5.4
tar xf libtool-2.5.4.tar.xz
cd libtool-2.5.4

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libltdl.a

cd /mnt/lfs/sources
rm -rf libtool-2.5.4
