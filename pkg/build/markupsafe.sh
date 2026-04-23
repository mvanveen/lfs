# markupsafe  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/markupsafe.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf markupsafe-3.0.2
tar xf markupsafe-3.0.2.tar.gz
cd markupsafe-3.0.2

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist Markupsafe

cd /mnt/lfs/sources
rm -rf markupsafe-3.0.2
