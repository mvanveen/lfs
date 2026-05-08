# bash  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/bash.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf bash-5.3
tar xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make

make DESTDIR=$LFS install

ln -sfv bash $LFS/bin/sh

cd /mnt/lfs/sources
rm -rf bash-5.3
