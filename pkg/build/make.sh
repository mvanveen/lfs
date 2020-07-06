cd /sources;


rm -rf make-4.3
tar xzf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr

make

make PERL5LIB=$PWD/tests/ check

make install
