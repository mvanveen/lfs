# gettext  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gettext.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gettext-0.26
tar xf gettext-0.26.tar.xz
cd gettext-0.26

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.26

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd /mnt/lfs/sources
rm -rf gettext-0.26
