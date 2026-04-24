# lz4  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/lz4.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf lz4-1.10.0
tar xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

make BUILD_STATIC=no PREFIX=/usr

make -j1 check

make BUILD_STATIC=no PREFIX=/usr install

cd /mnt/lfs/sources
rm -rf lz4-1.10.0
