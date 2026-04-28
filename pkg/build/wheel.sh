# wheel  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/wheel.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf wheel-0.46.1
tar xf wheel-0.46.1.tar.gz
cd wheel-0.46.1

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist wheel

cd /sources
rm -rf wheel-0.46.1
