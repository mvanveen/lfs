# bc  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bc.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf bc-7.0.3
tar xf bc-7.0.3.tar.xz
cd bc-7.0.3

CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

make

make test

make install

cd /mnt/lfs/sources
rm -rf bc-7.0.3
