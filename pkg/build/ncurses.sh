# ncurses  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/ncurses.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf ncurses-6.6
tar xf ncurses-6.6.tar.gz
cd ncurses-6.6

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

make

make DESTDIR=$PWD/dest install
install -vm755 "$(echo dest/usr/lib/libncursesw.so.6.*)" /usr/lib
rm -v  "$(echo dest/usr/lib/libncursesw.so.6.*)"
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so

cp -v -R doc -T /usr/share/doc/ncurses

make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding \
            --with-abi-version=5
make sources libs
cp -av lib/lib*.so.5* /usr/lib

cd /sources
rm -rf ncurses-6.6
