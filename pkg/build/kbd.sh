# kbd  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kbd.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf kbd-2.8.0
tar xf kbd-2.8.0.tar.xz
cd kbd-2.8.0

patch -Np1 -i ../kbd-2.8.0-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make

make install

cp -R -v docs/doc -T /usr/share/doc/kbd-2.8.0

cd /mnt/lfs/sources
rm -rf kbd-2.8.0
