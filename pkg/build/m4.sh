# m4  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/m4.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf m4-1.4.20
tar xf m4-1.4.20.tar.xz
cd m4-1.4.20

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
rm -rf m4-1.4.20
