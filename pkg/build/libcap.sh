# libcap  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libcap.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf libcap-2.76
tar xf libcap-2.76.tar.xz
cd libcap-2.76

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

make test

make prefix=/usr lib=lib install

cd /mnt/lfs/sources
rm -rf libcap-2.76
