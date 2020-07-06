cd /sources;

rm -rf elfutils-0.178
tar xf elfutils-0.178.tar.bz2
cd elfutils-0.178

./configure --prefix=/usr --disable-debuginfod

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
