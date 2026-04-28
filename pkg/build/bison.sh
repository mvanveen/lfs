# bison  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter07/bison.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf bison-3.8.2
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make

make install

cd /sources
rm -rf bison-3.8.2
