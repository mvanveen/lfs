#!/bin/bash
# meson — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "meson-1.8.3"
tar -xf "meson-1.8.3.tar.gz"
pushd "meson-1.8.3" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/meson.html

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson


popd >/dev/null
