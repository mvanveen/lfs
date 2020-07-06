#!/bin/bash
set -e
echo "Building man pages.."
echo "Approximate build time: less than 0.1 SBU"
echo "Required disk space: 27 MB"

# 6.8. Man-pages package describes C programming language functions,
# important device files, and significant configuration files

cd /sources;

rm -rf man-pages-5.05
tar xf man-pages-5.05.tar.xz
cd man-pages-5.05

make install
