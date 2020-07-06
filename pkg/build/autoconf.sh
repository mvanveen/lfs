cd /sources

rm -rf autoconf-2.69
tar xf autoconf-2.69.tar.xz
cd autoconf-2.69

sed '361 s/{/\\{/' -i bin/autoscan.in

./configure --prefix=/usr

make

make check

make install
