cd /mnt/lfs/sources

rm -rf sed-4.8
tar xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/tools

make

make check

make install
