cd /mnt/lfs/sources

rm -rf m4-1.4.19
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19

sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(build-aux/config.guess)

make

make check

make DESTDIR=$LFS install
