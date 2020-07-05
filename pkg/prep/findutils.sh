cd /mnt/lfs/sources

rm -rf findutils.tar.gz
tar xf findutils-4.7.0.tar.xz
cd findutils-4.7.0

./configure --prefix=/tools

make

make check

make install
