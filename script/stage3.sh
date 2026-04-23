#!/bin/bash
# Stage 3 (runs inside chroot, as root): finish chapter 7, then run chapters
# 8, 9, and 10. Invoked by script/stage2.sh after it chroots into $LFS.
set -euxo pipefail

# Inside the chroot, LFS is the root of the filesystem; force the var empty
# so scripts that still reference $LFS produce absolute paths.
export LFS=""
HERE=/sources/pkg

# Ch 7.5 + 7.6 - bare filesystem skeleton, initial /etc files.
bash "$HERE/ch7-chroot-tools/creatingdirs.sh"
bash "$HERE/ch7-chroot-tools/createfiles.sh"

# Ch 7.7..7.12 - additional temporary tools (gettext .. util-linux).
bash "$HERE/ch7-chroot-tools/run-all.sh"

# Ch 7.13 - cleanup (strip debug symbols, drop docs). Non-fatal if any part errors.
bash "$HERE/ch7-chroot-tools/cleanup.sh" || true

# Ch 8 - final system.
bash "$HERE/ch8-system/run-all.sh"

# Ch 9 - system configuration.
bash "$HERE/ch9-config/run-all.sh"

# Ch 10 - kernel + bootloader.
bash "$HERE/ch10-boot/run-all.sh"
