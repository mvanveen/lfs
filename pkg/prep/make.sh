cd /mnt/lfs/sources

rm -rf make-4.3
tar xzf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/tools --without-guile

make

make check

make install
