cd /sources

rm -rf check-0.14.0
tar xzf check-0.14.0.tar.gz
cd check-0.14.0

./configure --prefix=/usr

make

make check

make docdir=/usr/share/doc/check-0.14.0 install &&
sed -i '1 s/tools/usr/' /usr/bin/checkmk
