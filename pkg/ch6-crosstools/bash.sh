#!/bin/bash
# bash — from ch6-crosstools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "bash-5.3"
tar -xf "bash-5.3.tar.gz"
pushd "bash-5.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter06/bash.html

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make

make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh


popd >/dev/null
