#!/bin/bash
set -euxo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

bash "$HERE/fstab.sh"
bash "$HERE/kernel.sh"
bash "$HERE/grub.sh"
