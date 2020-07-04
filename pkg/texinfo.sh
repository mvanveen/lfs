cd /mnt/lfs/sources

rm -rf texinfo-6.7
tar xf texinfo-6.7.tar.xz
cd texinfo-6.7

./configure --prefix=/tools

make

make check

make install
