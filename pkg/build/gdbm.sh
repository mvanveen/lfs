# gdbm  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gdbm.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf gdbm-1.26
tar xf gdbm-1.26.tar.gz
cd gdbm-1.26

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

make check

make install

cd /mnt/lfs/sources
rm -rf gdbm-1.26
