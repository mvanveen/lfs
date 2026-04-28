# acl  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/acl.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf acl-2.3.2
tar xf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-2.3.2

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

cd /sources
rm -rf acl-2.3.2
