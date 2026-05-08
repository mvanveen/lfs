# gzip  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gzip.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf gzip-1.14
tar xf gzip-1.14.tar.xz
cd gzip-1.14

./configure --prefix=/usr

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf gzip-1.14
