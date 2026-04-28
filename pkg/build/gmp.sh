# gmp  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gmp.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf gmp-6.3.0
tar xf gmp-6.3.0.tar.xz
cd gmp-6.3.0

# book: `ABI=32 ./configure ...`  (x86-only; skipped on x86_64)
sed -i '/long long t1;/,+1s/()/(...)/' configure

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check 2>&1 | tee gmp-check-log \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log || :

make install
make install-html

cd /sources
rm -rf gmp-6.3.0
