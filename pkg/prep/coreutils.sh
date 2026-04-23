# coreutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter06/coreutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf coreutils-9.7
tar xf coreutils-9.7.tar.xz
cd coreutils-9.7

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make

make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd /mnt/lfs/sources
rm -rf coreutils-9.7
