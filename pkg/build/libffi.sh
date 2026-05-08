# libffi  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libffi.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf libffi-3.5.2
tar xf libffi-3.5.2.tar.gz
cd libffi-3.5.2

./configure --prefix=/usr    \
            --disable-static \
            --with-gcc-arch=native

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf libffi-3.5.2
