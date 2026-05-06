# bootscripts  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter09/bootscripts.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf lfs-bootscripts-20250827
tar xf lfs-bootscripts-20250827.tar.xz
cd lfs-bootscripts-20250827

make install

cd /sources
rm -rf lfs-bootscripts-20250827
