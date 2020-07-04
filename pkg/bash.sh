cd /mnt/lfs/sources;

rm -rf bash-5.0
tar xzf bash-5.0.tar.gz
cd bash-5.0

./configure --prefix=/tools --without-bash-malloc

make

#make tests

make install

ln -sv bash /tools/bin/sh
