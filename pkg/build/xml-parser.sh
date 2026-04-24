# xml-parser  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xml-parser.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf XML-Parser-2.47
tar xf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

perl Makefile.PL

make

make test

make install

cd /mnt/lfs/sources
rm -rf XML-Parser-2.47
