# pkgconf  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/pkgconf.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf pkgconf-2.5.1
tar xf pkgconf-2.5.1.tar.xz
cd pkgconf-2.5.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

make

make install

ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd /mnt/lfs/sources
rm -rf pkgconf-2.5.1
