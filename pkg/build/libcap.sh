cd /sources;

rm -rf libcap-2.31
tar xf libcap-2.31.tar.xz
cd libcap-2.31

sed -i '/install.*STA...LIBNAME/d' libcap/Makefile

make lib=lib

make test

make lib=lib install

chmod -v 755 /lib/libcap.so.2.31
