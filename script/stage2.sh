#!/bin/bash
# Stage 2 (runs as root on host): chapter 7 pre-chroot — ownership change,
# kernel virtual filesystem mounts, then pivot into chroot.
# https://www.linuxfromscratch.org/lfs/view/stable/chapter07/
set -euxo pipefail

export LFS=${LFS:-/mnt/lfs}

# Ch 7.2 - changing ownership from lfs to root.
chown --from lfs -R root:root "$LFS"/{usr,lib,var,etc,bin,sbin,tools} 2>/dev/null || true
case $(uname -m) in
  x86_64) chown --from lfs -R root:root "$LFS/lib64" 2>/dev/null || true ;;
esac

# Ch 7.3 - mount virtual kernel file systems.
mkdir -pv "$LFS"/{dev,proc,sys,run}
mountpoint -q "$LFS/dev"     || mount -v --bind /dev "$LFS/dev"
mountpoint -q "$LFS/dev/pts" || mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
mountpoint -q "$LFS/proc"    || mount -vt proc proc "$LFS/proc"
mountpoint -q "$LFS/sys"     || mount -vt sysfs sysfs "$LFS/sys"
mountpoint -q "$LFS/run"     || mount -vt tmpfs tmpfs "$LFS/run"
if [ -h "$LFS/dev/shm" ]; then
  install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
else
  mountpoint -q "$LFS/dev/shm" || mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
fi

# Ch 7.4 - enter chroot and execute stage3 inside it.
chroot "$LFS" /usr/bin/env -i                        \
    HOME=/root                                       \
    TERM="$TERM"                                     \
    PS1='(lfs chroot) \u:\w\$ '                      \
    PATH=/usr/bin:/usr/sbin                          \
    MAKEFLAGS="-j$(nproc)"                           \
    TESTSUITEFLAGS="-j$(nproc)"                      \
    /bin/bash --login -c "bash /sources/stage3.sh"
