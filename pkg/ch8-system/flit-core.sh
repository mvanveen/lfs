#!/bin/bash
# flit-core — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "flit_core-3.12.0"
tar -xf "flit_core-3.12.0.tar.gz"
pushd "flit_core-3.12.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/flit-core.html

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist flit_core


popd >/dev/null
