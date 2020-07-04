#TODO: don't hardcode version
cd /mnt/lfs/sources;

rm -rf binutils-2.34
tar xf binutils-2.34.tar.xz
cd binutils-2.34

mkdir -v build
cd build

../configure --prefix=/tools     \
	     --with-sysroot=$LFS \
	     --with-lib-path=/tools/lib \
	     --target=$LFS_TGT \
	     --disable-nls \
	     --disable-werror

make

mkdir -pv /tools/lib && ln -sv lib /tools/lib64

make install

cd ..
rm -rf binutils-2.3.4
