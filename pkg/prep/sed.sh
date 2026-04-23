# sed  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/sed.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf sed-4.9
tar xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd /mnt/lfs/sources
rm -rf sed-4.9
