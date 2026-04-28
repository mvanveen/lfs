# sed  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sed.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf sed-4.9
tar xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr

make
make html

chown -R tester .
if [ "${RUN_TESTS:-0}" = 1 ]; then
  su tester -c "PATH=$PATH make check" \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd /sources
rm -rf sed-4.9
