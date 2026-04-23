#!/bin/bash
# util-linux — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "util-linux-2.41.1"
tar -xf "util-linux-2.41.1.tar.xz"
pushd "util-linux-2.41.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/util-linux.html

./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.1

make

bash tests/run.sh --srcdir=$PWD --builddir=$PWD

touch /etc/fstab
chown -R tester .
su tester -c "make -k check"

make install


popd >/dev/null
