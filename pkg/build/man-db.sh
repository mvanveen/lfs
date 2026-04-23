# man-db  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-db.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf man-db-2.13.1
tar xf man-db-2.13.1.tar.xz
cd man-db-2.13.1

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.1 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=

make

make check

make install

cd /mnt/lfs/sources
rm -rf man-db-2.13.1
