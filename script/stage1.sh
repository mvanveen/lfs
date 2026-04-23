#!/bin/bash
# Stage 1 (runs as lfs@localhost): LFS 12.4 chapters 5 and 6 - cross
# toolchain into $LFS/tools plus the cross-compiled temporary userland
# into $LFS/usr.  The individual package scripts live in /mnt/lfs/sources/prep/.
set -e
# shellcheck source=/dev/null
. ~/.bashrc

cd "$LFS/sources"
md5sum -c md5sums || { echo "checksums failed" >&2; exit 1; }

sh /mnt/lfs/sources/prep/run-prep.sh
