#!/bin/bash
# iana-etc — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "iana-etc-20250807"
tar -xf "iana-etc-20250807.tar.gz"
pushd "iana-etc-20250807" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iana-etc.html

cp services protocols /etc


popd >/dev/null
