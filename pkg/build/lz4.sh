# lz4  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/lz4.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf lz4-1.10.0
tar xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

make BUILD_STATIC=no PREFIX=/usr

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make -j1 check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make BUILD_STATIC=no PREFIX=/usr install

cd /sources
rm -rf lz4-1.10.0
