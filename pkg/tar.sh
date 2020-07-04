cd /mnt/lfs/sources

rm -rf tar-1.32
tar xf tar-1.32.tar.xz
cd tar-1.32

./configure --prefix=/tools

make

make check

make install
