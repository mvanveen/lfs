#!/bin/bash
set -euxo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

bash "$HERE/etcshells.sh"
bash "$HERE/inputrc.sh"
bash "$HERE/locale.sh"
bash "$HERE/network.sh"
bash "$HERE/symlinks.sh"
bash "$HERE/usage.sh"
