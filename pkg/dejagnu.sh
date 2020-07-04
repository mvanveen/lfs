#TODO: don't hardcode version
cd /mnt/lfs/sources;

rm -rf dejagnu-1.6.2
tar xzf dejagnu-1.6.2.tar.gz

cd dejagnu-1.6.2


./configure --prefix=/tools

make install
make check
