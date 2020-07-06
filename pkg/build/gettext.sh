cd /sources;


rm -rf gettext-0.20.1
tar xf gettext-0.20.1.tar.xz
cd gettext-0.20.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.20.1

make

make check

make install

chmod -v 0755 /usr/lib/preloadable_libintl.so
