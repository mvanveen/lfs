cd /sources;

rm -rf gzip-1.10
tar xf gzip-1.10.tar.xz
cd gzip-1.10

./configure --prefix=/usr

make

make check

make install

mv -v /usr/bin/gzip /bin
