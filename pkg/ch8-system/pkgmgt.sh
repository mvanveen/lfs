#!/bin/bash
# pkgmgt — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/pkgmgt.html

grep -l 'libfoo.*deleted' /proc/*/maps | tr -cd 0-9\\n | xargs -r ps u

./configure --prefix=/usr/pkg/libfoo/1.1
make
make install

./configure --prefix=/usr
make
make DESTDIR=/usr/pkg/libfoo/1.1 install


