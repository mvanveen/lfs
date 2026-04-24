# jinja2  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/jinja2.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /mnt/lfs/sources
rm -rf jinja2-3.1.6
tar xf jinja2-3.1.6.tar.gz
cd jinja2-3.1.6

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist Jinja2

cd /mnt/lfs/sources
rm -rf jinja2-3.1.6
