# bash  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bash.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf bash-5.3
tar xf bash-5.3.tar.gz
cd bash-5.3

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.3

make

chown -R tester .

if [ "${RUN_TESTS:-0}" = 1 ]; then
LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
else
  echo 'skip tests (RUN_TESTS=0): expect heredoc'
fi

make install
# book: exec /usr/bin/bash --login  (skipped: script driver)

cd /sources
rm -rf bash-5.3
