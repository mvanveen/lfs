cd /mnt/lfs/sources

rm -rf gzip-1.10
tar xf gzip-1.10.tar.xz
cd gzip-1.10

./configure --prefix=/tools

make

make check

make install
