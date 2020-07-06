cd /sources

rm -rf libtool-2.4.6
tar xf libtool-2.4.6.tar.xz
cd libtool-2.4.6

./configure --prefix=/usr

make TESTSUITEFLAGS=-j24

make check

make install
