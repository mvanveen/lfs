#!/bin/bash
set -euxo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

bash "$HERE/binutils-pass1.sh"
bash "$HERE/gcc-pass1.sh"
bash "$HERE/linux-headers.sh"
bash "$HERE/glibc.sh"
bash "$HERE/gcc-libstdc++.sh"
