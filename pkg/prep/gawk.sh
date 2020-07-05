
cd /mnt/lfs/sources

rm -rf gawk-5.0.1
tar xf gawk-5.0.1.tar.xz
cd gawk-5.0.1

./configure --prefix=/tools

make

make check

make install
