# util-linux  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/util-linux.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf util-linux-2.41.1
tar xf util-linux-2.41.1.tar.xz
cd util-linux-2.41.1

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

cd /mnt/lfs/sources
rm -rf util-linux-2.41.1
