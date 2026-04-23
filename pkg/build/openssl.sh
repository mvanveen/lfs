# openssl  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/openssl.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf openssl-3.5.2
tar xf openssl-3.5.2.tar.gz
cd openssl-3.5.2

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.5.2

cp -vfr doc/* /usr/share/doc/openssl-3.5.2

cd /mnt/lfs/sources
rm -rf openssl-3.5.2
