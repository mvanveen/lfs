# libpipeline  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libpipeline.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf libpipeline-1.5.8
tar xf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8

./configure --prefix=/usr

make

make install

cd /sources
rm -rf libpipeline-1.5.8
