# file  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/file.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf file-5.46
tar xf file-5.46.tar.gz
cd file-5.46

./configure --prefix=/usr

make

make check

make install

cd /mnt/lfs/sources
rm -rf file-5.46
