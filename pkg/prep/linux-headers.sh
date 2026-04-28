# linux-headers  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf linux-6.16.1
tar xf linux-6.16.1.tar.xz
cd linux-6.16.1

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete || :
cp -rv usr/include $LFS/usr

cd /mnt/lfs/sources
rm -rf linux-6.16.1
