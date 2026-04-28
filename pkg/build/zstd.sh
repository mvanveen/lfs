# zstd  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zstd.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf zstd-1.5.7
tar xf zstd-1.5.7.tar.gz
cd zstd-1.5.7

make prefix=/usr

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd /sources
rm -rf zstd-1.5.7
