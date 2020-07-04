cd /mnt/lfs/sources;

rm -rf file-5.38
tar xzf file-5.38.tar.gz
cd file-5.38

./configure --prefix=/tools

make

make check

make install
