#!/bin/bash
# openssl — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "openssl-3.5.2"
tar -xf "openssl-3.5.2.tar.gz"
pushd "openssl-3.5.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/openssl.html

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.5.2

cp -vfr doc/* /usr/share/doc/openssl-3.5.2


popd >/dev/null
