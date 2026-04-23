#!/bin/bash
# gettext — from ch7-chroot-tools
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "gettext-0.26"
tar -xf "gettext-0.26.tar.xz"
pushd "gettext-0.26" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/gettext.html

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin


popd >/dev/null
