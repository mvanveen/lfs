# less  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/less.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf less-679
tar xf less-679.tar.gz
cd less-679

./configure --prefix=/usr --sysconfdir=/etc

make

make check

make install

cd /mnt/lfs/sources
rm -rf less-679
