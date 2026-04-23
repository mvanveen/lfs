# gawk  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/gawk.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf gawk-5.3.2
tar xf gawk-5.3.2.tar.xz
cd gawk-5.3.2

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

chown -R tester .
su tester -c "PATH=$PATH make check"

rm -f /usr/bin/gawk-5.3.2
make install

ln -sv gawk.1 /usr/share/man/man1/awk.1

install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.2

cd /mnt/lfs/sources
rm -rf gawk-5.3.2
