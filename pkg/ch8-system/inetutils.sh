#!/bin/bash
# inetutils — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "inetutils-2.6"
tar -xf "inetutils-2.6.tar.xz"
pushd "inetutils-2.6" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/inetutils.html

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

make check

make install

mv -v /usr/{,s}bin/ifconfig


popd >/dev/null
