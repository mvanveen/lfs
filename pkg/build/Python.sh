# Python  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter07/Python.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf Python-3.13.7
tar xf Python-3.13.7.tar.xz
cd Python-3.13.7

./configure --prefix=/usr       \
            --enable-shared     \
            --without-ensurepip \
            --without-static-libpython

make

make install

cd /sources
rm -rf Python-3.13.7
