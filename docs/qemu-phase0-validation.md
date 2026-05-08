# QEMU validation of Phase 0 fixes

Re-runs the QEMU smoke test from `docs/qemu-boot-test.md` against the
rootfs that has Phase 0 (lfs-bootscripts + sqlite + locale + network +
profile.d sourcing) applied.

## Setup

```sh
IMG=/var/lib/docker/rootfs/overlayfs/<cid>/lfs.img
mkdir -p /tmp/lfs-qemu-v2
sudo debugfs -R 'dump /boot/vmlinuz-6.16.1-lfs-12.4 /tmp/lfs-qemu-v2/vmlinuz' \
     "$IMG"?offset=$((2048*512))
sudo qemu-img create -f qcow2 -F raw -b "$IMG" /tmp/lfs-qemu-v2/overlay.qcow2

sudo qemu-system-x86_64 \
  -enable-kvm -cpu host -smp 2 -m 1024 \
  -kernel /tmp/lfs-qemu-v2/vmlinuz \
  -append 'root=/dev/vda1 rw console=ttyS0,115200 init=/bin/bash panic=15' \
  -drive file=/tmp/lfs-qemu-v2/overlay.qcow2,if=virtio,format=qcow2 \
  -nographic -no-reboot
```

## Results

| Test | Original status | After Phase 0 |
| ---- | --------------- | ------------- |
| `/etc/rc.d/init.d/rc` exists                        | ❌ missing                  | ✅ `BOOTSCRIPTS-OK` |
| `python3 -c 'import sqlite3'`                       | ❌ ModuleNotFoundError       | ✅ `SQLITE-OK 3.50.4` |
| `bash -n /etc/profile`                              | ❌ syntax error (empty else) | ✅ `PROFILE-PARSES-OK` |
| `/etc/profile` sources `/etc/profile.d/*.sh`        | ❌ never sourced             | ✅ `PROFILE-SOURCES-D-OK` |
| `/etc/resolv.conf` has real nameservers             | ❌ `<Your DNS>` placeholders | ✅ `1.1.1.1`, `8.8.8.8` |
| `/etc/profile.d/` populated                          | ❌ empty                     | ✅ `pkgsrc.sh`, `ssl-cert.sh` |

All five regressions identified in the original `qemu-boot-test` are fixed
on a real QEMU/KVM boot, not just inside the chroot.

## Resolves Fossil tickets

Closes (regression-watch):
- `bfa8d1afce` — lfs-bootscripts missing from BUILD_ORDER
- `7362cf14b8` — Python sqlite3 silently absent
- `36cc0d7d71` — /etc/profile empty `else` branch
- `2f9b73d48b` — /etc/resolv.conf placeholders
- `00b1493b03` — /etc/profile didn't source /etc/profile.d/*.sh

Closes (workaround landed):
- `3980b042fd` — No CA bundle on LFS (mitigated via bootstrap.sh staging
  cacert.pem and SSL_CERT_FILE)
- `667a947686` — pkgsrc fetch ↔ openssl bootstrap circular (mitigated via
  PKG_OPTIONS.libfetch + prefetch.sh)
