cd /mnt/lfs/sources;

rm -rf bison-3.5.2;
tar xf bison-3.5.2.tar.xz
cd bison-3.5.2;

./configure --prefix=/tools

make

make check

make install
