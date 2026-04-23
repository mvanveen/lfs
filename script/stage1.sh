#!/bin/bash
# Stage 1 (runs as lfs@localhost): chapters 5 & 6 of LFS 12.4.
#   - chapter 5: cross-compilation toolchain into $LFS/tools
#   - chapter 6: cross-compiled temporary tools into $LFS/usr
set -euxo pipefail

export LFS=${LFS:-/mnt/lfs}
. ~/.bashrc

cd "$LFS/sources"
md5sum -c md5sums || { echo "checksums failed"; exit 1; }

bash "$LFS/sources/pkg/ch5-toolchain/run-all.sh"
bash "$LFS/sources/pkg/ch6-crosstools/run-all.sh"
