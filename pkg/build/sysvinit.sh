cd /sources;


rm -rf sysvinit-2.96
tar xf sysvinit-2.96.tar.xz
cd sysvinit-2.96

patch -Np1 -i ../sysvinit-2.96-consolidated-1.patch

make

make install
