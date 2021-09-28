#!/bin/bash
set -e

cd /sources

rm -rf linux-5.13.19
tar -xzf linux-5.13.19.tar.gz
cd linux-5.13.19;

make mrproper
make headers

find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr
