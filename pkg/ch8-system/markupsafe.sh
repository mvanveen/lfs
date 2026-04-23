#!/bin/bash
# markupsafe — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "markupsafe-3.0.2"
tar -xf "markupsafe-3.0.2.tar.gz"
pushd "markupsafe-3.0.2" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/markupsafe.html

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist Markupsafe


popd >/dev/null
