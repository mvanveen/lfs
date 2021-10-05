cd /mnt/lfs/sources;

rm -rf toybox-0.8.5
tar xzf toybox-0.8.5.tar.gz
cd toybox-0.8.5

make defconfig
LDFLAGS="--prefix=$LFS" make defconfig toybox
PREFIX="/tmp/toybox" make install_flat
