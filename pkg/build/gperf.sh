# gperf  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gperf.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf gperf-3.3
tar xf gperf-3.3.tar.gz
cd gperf-3.3

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.3

make

make check

make install

cd /mnt/lfs/sources
rm -rf gperf-3.3
