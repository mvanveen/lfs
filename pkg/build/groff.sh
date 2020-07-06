cd /sources

rm -rf groff-1.22.4
tar xf groff-1.22.4.tar.gz
cd groff-1.22.4

PAGE=letter ./configure --prefix=/usr

make -j1

make install
