#!/bin/bash
# packaging — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "packaging-25.0"
tar -xf "packaging-25.0.tar.gz"
pushd "packaging-25.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/packaging.html

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist packaging


popd >/dev/null
