# man-pages  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/man-pages.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf man-pages-6.15
tar xf man-pages-6.15.tar.xz
cd man-pages-6.15

rm -v man3/crypt*

make -R GIT=false prefix=/usr install

cd /mnt/lfs/sources
rm -rf man-pages-6.15
