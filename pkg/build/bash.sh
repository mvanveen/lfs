#!/usr/bin/env bash
source /home/lfs/.bashrc

set -ex

source /home/lfs/.bashrc

rm -rf bash-5.1.8
tar xzf bash-5.1.8.tar.gz
cd bash-5.1.8

#patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch

./configure --prefix=/usr                    \
	    --build=$(support/config.guess) \
	    --host=$LFS_TGT \
            --without-bash-malloc            \

make

make DESTDIR=$LFS install


mkdir -p $LFS/bin
ln -sv bash $LFS/bin/sh

#exec /bin/bash --login +h
