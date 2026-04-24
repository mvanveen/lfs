# acl  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/acl.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf acl-2.3.2
tar xf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2

make

make check

make install

cd /mnt/lfs/sources
rm -rf acl-2.3.2
