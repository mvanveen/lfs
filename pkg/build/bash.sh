# bash  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bash.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf bash-5.3
tar xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

make

chown -R tester .

LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install
# book: exec /usr/bin/bash --login  (skipped: script driver)

cd /mnt/lfs/sources
rm -rf bash-5.3
