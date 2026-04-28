# texinfo  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/texinfo.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf texinfo-7.2
tar xf texinfo-7.2.tar.xz
cd texinfo-7.2

sed 's/! $output_file eq/$output_file ne/' -i tp/Texinfo/Convert/*.pm

./configure --prefix=/usr

make

if [ "${RUN_TESTS:-0}" = 1 ]; then
  make check \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd

cd /sources
rm -rf texinfo-7.2
