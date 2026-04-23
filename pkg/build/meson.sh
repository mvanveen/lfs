# meson  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/meson.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf meson-1.8.3
tar xf meson-1.8.3.tar.gz
cd meson-1.8.3

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /mnt/lfs/sources
rm -rf meson-1.8.3
