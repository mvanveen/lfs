# iana-etc  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iana-etc.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf iana-etc-20250807
tar xf iana-etc-20250807.tar.gz
cd iana-etc-20250807

cp services protocols /etc

cd /sources
rm -rf iana-etc-20250807
