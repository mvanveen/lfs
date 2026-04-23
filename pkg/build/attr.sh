# attr  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/attr.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf attr-2.5.2
tar xf attr-2.5.2.tar.gz
cd attr-2.5.2

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make

make check

make install

cd /mnt/lfs/sources
rm -rf attr-2.5.2
