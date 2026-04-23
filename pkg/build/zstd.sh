# zstd  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/zstd.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf zstd-1.5.7
tar xf zstd-1.5.7.tar.gz
cd zstd-1.5.7

make prefix=/usr

make check

make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd /mnt/lfs/sources
rm -rf zstd-1.5.7
