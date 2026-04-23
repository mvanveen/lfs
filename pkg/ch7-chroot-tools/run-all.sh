#!/bin/bash
set -euxo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

bash "$HERE/gettext.sh"
bash "$HERE/bison.sh"
bash "$HERE/perl.sh"
bash "$HERE/Python.sh"
bash "$HERE/texinfo.sh"
bash "$HERE/util-linux.sh"
