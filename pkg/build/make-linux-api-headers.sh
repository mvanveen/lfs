#!/bin/bash
set -e
echo "Building Linux API headers.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 921 MB"


cd /sources

rm -rf linux-5.5.3
tar -xzf linux-5.5.3.tar.gz
cd linux-5.5.3;

make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include/* /usr/include
