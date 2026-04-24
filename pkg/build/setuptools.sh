# setuptools  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/setuptools.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf setuptools-80.9.0
tar xf setuptools-80.9.0.tar.gz
cd setuptools-80.9.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist setuptools

cd /mnt/lfs/sources
rm -rf setuptools-80.9.0
