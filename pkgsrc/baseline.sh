#!/bin/bash
# Build (or pkgin-install) a baseline userland from pkgsrc.
#
# Reads pkg/pkgsrc-baseline.list (one pkgsrc category/name per line,
# blank lines and # comments allowed).  For each entry, we either
#   - pkgin -y install <name>          (if a binary is available locally)
#   - cd $PKGSRCDIR/<entry> && bmake install clean   (otherwise)
#
# Idempotent: skips packages already in pkg_info.

set -euo pipefail

QUARTER=${QUARTER:-2025Q3}
SRV=${SRV:-/srv/sources}
PKGSRCDIR=$SRV/pkgsrc/$QUARTER
LIST=${LIST:-pkg/pkgsrc-baseline.list}

if [ ! -d "$PKGSRCDIR" ]; then
    echo "pkgsrc tree missing at $PKGSRCDIR; run pkgsrc/bootstrap.sh first" >&2
    exit 1
fi

export PATH=/opt/pkg/sbin:/opt/pkg/bin:$PATH

installed() { pkg_info -e "$1" >/dev/null 2>&1; }

while read -r line; do
    line=${line%%#*}
    line=${line## }
    line=${line%% }
    [ -z "$line" ] && continue
    cat=${line%%/*}
    name=${line##*/}
    if installed "$name"; then
        echo "== $line  already installed"
        continue
    fi
    if command -v pkgin >/dev/null 2>&1 && pkgin -y install "$name" 2>/dev/null; then
        echo "== $line  installed via pkgin"
        continue
    fi
    echo "== $line  building from source"
    cd "$PKGSRCDIR/$cat/$name"
    bmake install clean clean-depends
done < "$LIST"

echo
echo "baseline complete; installed packages:"
pkg_info | sort
