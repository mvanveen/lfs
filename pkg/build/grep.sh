# grep  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/grep.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf grep-3.12
tar xf grep-3.12.tar.xz
cd grep-3.12

sed -i "s/echo/#echo/" src/egrep.sh

./configure --prefix=/usr

make

make check

make install

cd /mnt/lfs/sources
rm -rf grep-3.12
