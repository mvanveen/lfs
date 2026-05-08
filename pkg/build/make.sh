# make  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/make.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf make-4.4.1
tar xf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr

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
rm -rf make-4.4.1
