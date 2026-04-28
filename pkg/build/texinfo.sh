# texinfo  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter07/texinfo.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf texinfo-7.2
tar xf texinfo-7.2.tar.xz
cd texinfo-7.2

./configure --prefix=/usr

make

make install

cd /sources
rm -rf texinfo-7.2
