# util-linux  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/util-linux.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
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

if [ "${RUN_TESTS:-0}" = 1 ]; then bash tests/run.sh --srcdir=$PWD --builddir=$PWD; else echo "skip tests/run.sh (RUN_TESTS=0)"; fi

touch /etc/fstab
chown -R tester .
if [ "${RUN_TESTS:-0}" = 1 ]; then
  su tester -c "make -k check" \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf util-linux-2.41.1
