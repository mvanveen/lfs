cd /mnt/lfs/sources

rm -rf linux-5.5.9
tar -xzf linux-5.5.9.tar.gz
cd linux-5.5.9

make mrproper

make headers

mkdir -p /tools/include
cp -rv usr/include/* /tools/include
