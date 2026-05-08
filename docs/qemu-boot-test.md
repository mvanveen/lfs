# QEMU boot test of the LFS 12.4 image

First smoke test of the rootfs produced by the full build (head `d74f220`,
branch `lfs-12.4`). The 30 GB MBR ext4 loopback image lives in the build
container at `/var/lib/docker/rootfs/overlayfs/<cid>/lfs.img`. We boot it on
the host with KVM + virtio, bypassing GRUB (which we never installed).

## How to reproduce

```sh
IMG=/var/lib/docker/rootfs/overlayfs/<cid>/lfs.img
mkdir -p /tmp/lfs-qemu

# Pull the kernel out of the image without mounting (loop device is held by Docker).
sudo debugfs -R "dump /boot/vmlinuz-6.16.1-lfs-12.4 /tmp/lfs-qemu/vmlinuz" \
     "$IMG"?offset=$((2048*512))

# Throwaway qcow2 overlay so the original image stays clean.
sudo qemu-img create -f qcow2 -F raw -b "$IMG" /tmp/lfs-qemu/overlay.qcow2
sudo chown $USER /tmp/lfs-qemu/overlay.qcow2

sudo qemu-system-x86_64 \
  -enable-kvm -cpu host -smp 2 -m 1024 \
  -kernel /tmp/lfs-qemu/vmlinuz \
  -append 'root=/dev/vda1 rw console=ttyS0,115200 init=/bin/bash panic=15' \
  -drive file=/tmp/lfs-qemu/overlay.qcow2,if=virtio,format=qcow2 \
  -nographic -no-reboot
```

Full driver script: `expect`-based, see `qemu-boot-session.log` for the
transcript. `qemu-init3-boot.log` is a separate run with the default
`init=/sbin/init` (sysvinit), which fails at runlevel 3 — see issue 1.

## What works

- Linux 6.16.1 boots, virtio-blk attaches, ext4 root mounts r/w, journal recovers.
- `/sbin/init` (sysvinit) starts and reaches `Entering runlevel: 3`.
- With `init=/bin/bash` we get an interactive root shell.
- Toolchain & runtime sanity:
  - glibc 2.42, gcc 15.2.0, bash 5.3.0, coreutils 9.7
  - openssl 3.5.2, perl 5.42
- Disk: 5.0 G used / 30 G; /usr/bin=647, /usr/lib=399, /usr/sbin=138 entries.
- `/boot` contains `vmlinuz-6.16.1-lfs-12.4`, `System.map-6.16.1`,
  `config-6.16.1`, `grub/` (config only, no installed bootloader).

## Issues found

1. **No `/etc/rc.d/init.d/rc`.** `lfs-bootscripts` is in `packages.txt` but
   never wired into `BUILD_ORDER` and has no `pkg/build/*.sh` driver, so the
   sysvinit boot dies immediately after `INIT: Entering runlevel: 3` with
   `INIT: cannot execute "/etc/rc.d/init.d/rc"`. Need to add an
   `lfs-bootscripts` driver per LFS book ch 9.2.
2. **`gcc` can't find `cc1`** when invoked with a stripped PATH. `cc1` is at
   `/usr/libexec/gcc/x86_64-pc-linux-gnu/15.2.0/cc1`; a normal login shell
   (with `/etc/profile` sourced) would find it via gcc's libexec lookup, but
   `init=/bin/bash` skips profile. Cosmetic for this test.
3. **Python 3 `_sqlite3` extension missing.** `import sqlite3` fails:
   `ModuleNotFoundError: No module named '_sqlite3'`. Either sqlite headers
   weren't visible when CPython's setup.py probed extensions, or the
   `_sqlite3` build was silently skipped. Check the python install log's
   "could not be built" list.
4. **Image is not standalone-bootable.** GRUB was built but never installed —
   `grub-install`, `grub-mkrescue`, and `xorriso` are still commented out in
   `pkg/build/grub-final.sh` (intentional; loopback-only build). Boot here
   only worked because we hand-passed `-kernel`.

## Notes

- `qemu-img` qcow2 overlay means the original `lfs.img` was never touched.
- KVM is available on this VM (`/dev/kvm` exists; user added to `kvm` group).
- The serial console works fine; useful for scripted regression tests once
  the bootscripts gap is closed.
