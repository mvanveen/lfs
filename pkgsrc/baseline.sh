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
export SSL_CERT_FILE=${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}
export SSL_CERT_DIR=${SSL_CERT_DIR:-/etc/ssl/certs}

installed() { pkg_info -e "$1" >/dev/null 2>&1; }

# ----- pre-baseline: bootstrap a working fetch tool then pkgin ----------
# pkgin needs curl (or another fetch tool) for dep resolution, but on a
# fresh LFS we have neither. Build them in this exact order from source.
# www/curl needs distfiles to already be staged in $DISTDIR (the
# bootstrap-built net/fetch lacks TLS).
if ! installed curl; then
    echo "== www/curl  building from source (preboot)"
    cd "$PKGSRCDIR/www/curl"
    bmake install clean clean-depends
else
    echo "== www/curl  already installed (preboot)"
fi

# Once curl is installed, switch pkgsrc's fetcher to it so HTTPS
# distfiles work without further pre-staging.
MK=/opt/pkg/etc/mk.conf
if command -v curl >/dev/null 2>&1 && ! grep -q '^FETCH_USING=' "$MK" 2>/dev/null; then
    echo "FETCH_USING=    curl" >> "$MK"
    echo "== switched pkgsrc fetcher to curl (HTTPS now works)"
fi

# pkgin closes the loop: binary package management on top of curl.
if ! installed pkgin; then
    echo "== pkgtools/pkgin  building from source"
    cd "$PKGSRCDIR/pkgtools/pkgin"
    bmake install clean clean-depends
fi

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
