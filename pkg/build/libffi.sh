cd /sources

rm -rf libffi-3.3
tar xzf libffi-3.3.tar.gz
cd libffi-3.3

./configure --prefix=/usr --disable-static --with-gcc-arch=native

make

make check

make install
