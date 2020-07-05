#TODO: don't hardcode version
cd /mnt/lfs/sources

rm -rf coreutils-8.31
tar xf coreutils-8.31.tar.xz 
cd coreutils-8.31

./configure --prefix=/tools --enable-install-program=hostname

make

make install
