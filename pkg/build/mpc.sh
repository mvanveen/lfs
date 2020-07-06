cd /sources

rm -rf mpc-1.1.0
tar xzf mpc-1.1.0.tar.gz
cd mpc-1.1.0

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.1.0

make

make html

make check

make install

make install-html
