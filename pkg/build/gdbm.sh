cd /sources

rm -rf gdbm-1.18.1
tar xzf gdbm-1.18.1.tar.gz
cd gdbm-1.18.1

./configure --prefix=/usr --disable-static --enable-libgdm-compat

make

make check

make install
