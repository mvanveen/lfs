# inetutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/inetutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf inetutils-2.6
tar xf inetutils-2.6.tar.xz
cd inetutils-2.6

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

cd /mnt/lfs/sources
rm -rf inetutils-2.6
