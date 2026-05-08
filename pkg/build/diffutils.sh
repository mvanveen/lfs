# diffutils  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/diffutils.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf diffutils-3.12
tar xf diffutils-3.12.tar.xz
cd diffutils-3.12

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
rm -rf diffutils-3.12
