cd /sources

rm -rf zstd-1.4.4
tar xzf zstd-1.4.4.tar.gz
cd zstd-1.4.4

make

make prefix=/usr install

rm -v /usr/lib/libzstd.a
mv -v /usr/lib/libzstd.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
