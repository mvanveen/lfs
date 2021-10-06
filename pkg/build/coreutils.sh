#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

cd /mnt/lfs/sources

rm -rf coreutils-8.32
tar xf coreutils-8.32.tar.xz
cd coreutils-8.32

./configure \
    --prefix=/usr                     \
    --host=$LFS_TGT                   \
    --build=$(build-aux/config.guess) \
    --enable-install-program=hostname \
    --enable-no-install-program=kill,uptime


make

make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

#patch -Np1 -i ../coreutils-8.31-i18n-1.patch
#
#sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
#
#autoreconf -fiv
#FORCE_UNSAFE_CONFIGURE=1 ./configure \
#            --prefix=/usr            \
#            --enable-no-install-program=kill,uptime
#
#make
#
#make NON_ROOT_USERNAME=nobody check-root
#
#echo "dummy:x:1000:nobody" >> /etc/group
#
#chown -Rv nobody .
#
#su nobody -s /bin/bash \
#          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
#
#sed -i '/dummy/d' /etc/group
#
#make install
#
#mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
#mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
#mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
#mv -v /usr/bin/chroot /usr/sbin
#mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
#sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
#
#mv -v /usr/bin/{head,nice,sleep,touch} /bin
