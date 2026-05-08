# automake  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/automake.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf automake-1.18.1
tar xf automake-1.18.1.tar.xz
cd automake-1.18.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.18.1

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make -j$(($(nproc)>4?$(nproc):4)) check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf automake-1.18.1
