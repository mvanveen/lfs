#!/bin/bash
# jinja2 — from ch8-system
# See source URL at top of command list below.
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
# (book commands are reproduced verbatim; these warnings are intentional)
set -euxo pipefail

cd "$LFS/sources"
rm -rf "jinja2-3.1.6"
tar -xf "jinja2-3.1.6.tar.gz"
pushd "jinja2-3.1.6" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/jinja2.html

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist Jinja2


popd >/dev/null
