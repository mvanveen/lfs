# expat  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/expat.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf expat-2.7.1
tar xf expat-2.7.1.tar.xz
cd expat-2.7.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.1

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.7.1

cd /sources
rm -rf expat-2.7.1
