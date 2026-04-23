# psmisc  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/psmisc.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf psmisc-23.7
tar xf psmisc-23.7.tar.xz
cd psmisc-23.7

./configure --prefix=/usr

make

make check

make install

cd /mnt/lfs/sources
rm -rf psmisc-23.7
