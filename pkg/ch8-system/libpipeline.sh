#!/bin/bash
# libpipeline — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/libpipeline.html

./configure --prefix=/usr

make

make install

