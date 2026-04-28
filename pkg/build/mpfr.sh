# mpfr  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpfr.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf mpfr-4.2.2
tar xf mpfr-4.2.2.tar.xz
cd mpfr-4.2.2

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

make
make html

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install
make install-html

cd /sources
rm -rf mpfr-4.2.2
