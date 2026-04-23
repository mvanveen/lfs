# gmp  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gmp.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gmp-6.3.0
tar xf gmp-6.3.0.tar.xz
cd gmp-6.3.0

ABI=32 ./configure ...

sed -i '/long long t1;/,+1s/()/(...)/' configure

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

cd /mnt/lfs/sources
rm -rf gmp-6.3.0
