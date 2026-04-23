#!/bin/bash
# udev — from ch9-config
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "systemd-257.8"
tar -xf "systemd-257.8.tar.gz"
pushd "systemd-257.8" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter09/udev.html


popd >/dev/null
