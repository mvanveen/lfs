# findutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/findutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf findutils-4.10.0
tar xf findutils-4.10.0.tar.xz
cd findutils-4.10.0

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

chown -R tester .
if [ "${RUN_TESTS:-0}" = 1 ]; then
  su tester -c "PATH=$PATH make check" \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf findutils-4.10.0
