cd /sources

rm -rf less-551
tar xzf less-551.tar.gz
cd less-551

./configure --prefix=/usr --sysconfdir=/etc

make

make install
