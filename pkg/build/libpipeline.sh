# libpipeline  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libpipeline.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
./configure --prefix=/usr

make

make install
