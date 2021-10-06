#!/usr/bin/env bash
#trap 'failed' 0

set -e
set -x

source /home/lfs/.bashrc

cd /mnt/lfs/sources
source binutils.sh

cd /mnt/lfs/sources
source gcc-pass1.sh

cd /mnt/lfs/sources
source make-linux-api-headers.sh

cd /mnt/lfs/sources
source toybox.sh

cd /mnt/lfs/sources
source glibc.sh

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/libstdcplusplus-pass1.sh"

cd /mnt/lfs/sources
su lfs -c "source m4.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/ncurses.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/bash.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/coreutils.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/diffutils.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/file.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/findutils.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/gawk.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/grep.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/gzip.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/make.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/patch.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/sed.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/tar.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/xz.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/binutils-pass2.sh"

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/gcc-pass2.sh"
