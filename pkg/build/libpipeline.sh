cd /sources

rm -rf libpipeline-1.5.2
tar xzf libpipeline-1.5.2.tar.gz
cd libpipeline-1.5.2

./configure --prefix=/usr

make

make check

make install
