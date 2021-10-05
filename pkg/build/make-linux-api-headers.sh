#!/bin/bash
set -e

rm -rf linux-5.13.19
tar -xzf linux-5.13.19.tar.gz

cd linux-5.13.19;

chmod -R 777 .
chown -R lfs .

su lfs -c "make mrproper"
su lfs -c "make headers"

find usr/include -name '.*' -delete
rm usr/include/Makefile
mkdir -p /mnt/lfs/usr/include/
cp -rv usr/include/* /mnt/lfs/usr/include/

chmod -R 777 /mnt/lfs/usr
chown -R lfs /mnt/lfs/usr
