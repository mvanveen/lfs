# kernel  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter10/kernel.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf linux-6.16.1
tar xf linux-6.16.1.tar.xz
cd linux-6.16.1

make mrproper
make defconfig   # book uses `make menuconfig`; use defconfig for unattended build
make

make modules_install

mount /boot

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.16.1-lfs-12.4

cp -iv System.map /boot/System.map-6.16.1

cp -iv .config /boot/config-6.16.1

cp -r Documentation -T /usr/share/doc/linux-6.16.1

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

cd /sources
rm -rf linux-6.16.1
