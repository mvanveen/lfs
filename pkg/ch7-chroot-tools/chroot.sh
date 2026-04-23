#!/bin/bash
# chroot — from ch7-chroot-tools
# See source URL at top of command list below.
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/chroot.html

chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login


