cd /mnt/lfs/sources

rm -rf diffutils-3.7
tar xf diffutils-3.7.tar.xz
cd diffutils-3.7

./configure --prefix=/tools

make

make check

make install
