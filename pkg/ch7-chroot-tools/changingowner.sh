#!/bin/bash
# changingowner — from ch7-chroot-tools
# See source URL at top of command list below.
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/changingowner.html

chown --from lfs -R root:root $LFS/{usr,var,etc,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac


