# procps-ng  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/procps-ng.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf procps-ng-4.0.5
tar xf procps-ng-4.0.5.tar.xz
cd procps-ng-4.0.5

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit

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
rm -rf procps-ng-4.0.5
