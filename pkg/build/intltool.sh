# intltool  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/intltool.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf intltool-0.51.0
tar xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /mnt/lfs/sources
rm -rf intltool-0.51.0
