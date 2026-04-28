# packaging  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/packaging.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf packaging-25.0
tar xf packaging-25.0.tar.gz
cd packaging-25.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist packaging

cd /sources
rm -rf packaging-25.0
