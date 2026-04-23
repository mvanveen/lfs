# mpc  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/mpc.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf mpc-1.3.1
tar xf mpc-1.3.1.tar.gz
cd mpc-1.3.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

make check

make install
make install-html

cd /mnt/lfs/sources
rm -rf mpc-1.3.1
