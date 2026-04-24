#!/bin/bash
# Outside chroot: mount the virtual kernel filesystems then chroot into
# $LFS and run as-chroot.sh.
set -euo pipefail

LFS=${LFS:-/mnt/lfs}

# Ch 7.2 - changing ownership of anything still owned by the lfs user.
chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools} 2>/dev/null || true
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 2>/dev/null || true ;;
esac

# Ch 7.3 - mount virtual kernel file systems.
mkdir -pv $LFS/{dev,proc,sys,run}
mountpoint -q $LFS/dev     || mount -v --bind /dev $LFS/dev
mountpoint -q $LFS/dev/pts || mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mountpoint -q $LFS/proc    || mount -vt proc proc $LFS/proc
mountpoint -q $LFS/sys     || mount -vt sysfs sysfs $LFS/sys
mountpoint -q $LFS/run     || mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mountpoint -q $LFS/dev/shm || mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

# Forward FORCE (comma-separated pkg names to re-run) into the chroot.
FORCE="${FORCE:-}"

# Ch 7.4 - enter chroot and continue.
chroot "$LFS" /usr/bin/env -i                 \
    HOME=/root                                \
    TERM="$TERM"                              \
    PS1='(lfs chroot) \u:\w\$ '               \
    PATH=/usr/bin:/usr/sbin                   \
    MAKEFLAGS="-j$(nproc)"                    \
    TESTSUITEFLAGS="-j$(nproc)"               \
    FORCE="$FORCE"                            \
    /bin/bash --login -c "bash /sources/build/as-chroot.sh"
