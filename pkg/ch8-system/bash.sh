#!/bin/bash
# bash — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "bash-5.3"
tar -xf "bash-5.3.tar.gz"
pushd "bash-5.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/bash.html

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
# exec /usr/bin/bash --login   # skipped: automated build
popd >/dev/null
