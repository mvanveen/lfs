cd /mnt/lfs/sources;

rm -rf gettext-0.20.1
tar xf gettext-0.20.1.tar.xz
cd gettext-0.20.1

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /tools/bin
