# flex  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/flex.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf flex-2.6.4
tar xf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

make check

make install

ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd /mnt/lfs/sources
rm -rf flex-2.6.4
