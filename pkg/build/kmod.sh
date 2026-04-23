# kmod  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/kmod.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf kmod-34.2
tar xf kmod-34.2.tar.xz
cd kmod-34.2

mkdir -p build
cd       build

meson setup --prefix=/usr ..    \
            --buildtype=release \
            -D manpages=false

ninja

ninja install

cd /mnt/lfs/sources
rm -rf kmod-34.2
