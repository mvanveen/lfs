# gettext  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter07/gettext.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf gettext-0.26
tar xf gettext-0.26.tar.xz
cd gettext-0.26

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /mnt/lfs/sources
rm -rf gettext-0.26
