cd /sources

rm -rf grep-3.4
tar xf grep-3.4.tar.xz
cd grep-3.4

./configure --prefix=/usr --bindir=/bin

make

make check

make install
