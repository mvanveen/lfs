# make  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/make.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf make-4.4.1
tar xf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install

cd /mnt/lfs/sources
rm -rf make-4.4.1
