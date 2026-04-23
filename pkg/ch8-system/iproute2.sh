#!/bin/bash
# iproute2 — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "iproute2-6.16.0"
tar -xf "iproute2-6.16.0.tar.xz"
pushd "iproute2-6.16.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iproute2.html

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns

make SBINDIR=/usr/sbin install

install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.16.0


popd >/dev/null
