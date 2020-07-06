cd /sources

rm -rf automake-1.16.1
tar xf automake-1.16.1.tar.xz
cd automake-1.16.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.1

make

make -j4 check

make install
