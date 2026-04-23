# sysvinit  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sysvinit.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf sysvinit-3.14
tar xf sysvinit-3.14.tar.xz
cd sysvinit-3.14

patch -Np1 -i ../sysvinit-3.14-consolidated-1.patch

make

make install

cd /mnt/lfs/sources
rm -rf sysvinit-3.14
