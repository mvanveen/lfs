# iproute2  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iproute2.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
cd /mnt/lfs/sources
rm -rf iproute2-6.16.0
tar xf iproute2-6.16.0.tar.xz
cd iproute2-6.16.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns

make SBINDIR=/usr/sbin install

install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.16.0

cd /mnt/lfs/sources
rm -rf iproute2-6.16.0
