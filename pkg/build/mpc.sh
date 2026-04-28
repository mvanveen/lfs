# mpc  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpc.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf mpc-1.3.1
tar xf mpc-1.3.1.tar.gz
cd mpc-1.3.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

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
rm -rf mpc-1.3.1
