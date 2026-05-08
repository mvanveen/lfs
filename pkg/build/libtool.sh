# libtool  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libtool.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf libtool-2.5.4
tar xf libtool-2.5.4.tar.xz
cd libtool-2.5.4

./configure --prefix=/usr

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

rm -fv /usr/lib/libltdl.a

cd /sources
rm -rf libtool-2.5.4
