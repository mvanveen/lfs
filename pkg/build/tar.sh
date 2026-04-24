# tar  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/tar.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf tar-1.35
tar xf tar-1.35.tar.xz
cd tar-1.35

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd /mnt/lfs/sources
rm -rf tar-1.35
