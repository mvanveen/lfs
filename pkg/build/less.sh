# less  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/less.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf less-679
tar xf less-679.tar.gz
cd less-679

./configure --prefix=/usr --sysconfdir=/etc

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf less-679
