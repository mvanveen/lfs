#!/bin/bash
# cleanup — from ch7-chroot-tools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/cleanup.html

rm -rf /usr/share/{info,man,doc}/*

find /usr/{lib,libexec} -name \*.la -delete

rm -rf /tools

exit

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

cd $LFS
tar -cJpf $HOME/lfs-temp-tools-12.4.tar.xz .


