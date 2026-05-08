#!/bin/bash
# Pre-populate /srv/sources/distfiles from outside the chroot, using the
# host's fetch tool (curl). Works around the chicken-and-egg problem
# where pkgsrc's bootstrap-built `net/fetch` lacks TLS, and the LFS base
# system has no curl/wget either.
#
# Two modes:
#   1. URL list mode: read URLs from $LIST_FILE, one per line.
#      Lines starting with '#' are skipped.
#   2. pkgsrc fetch-list mode: cd $PKGSRCDIR/<cat>/<name> && bmake fetch-list
#      generates the canonical fetch commands; we strip them down to URLs.
#
# Idempotent: skips files already present (and matching size if
# distinfo says so).

set -euo pipefail

SRV=${SRV:-/srv/sources}
DISTDIR=$SRV/distfiles
QUARTER=${QUARTER:-2025Q3}
PKGSRCDIR=$SRV/pkgsrc/$QUARTER
LIST_FILE=${LIST_FILE:-pkg/pkgsrc-baseline.list}

mkdir -p "$DISTDIR"
cd "$DISTDIR"

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl required (host-side prefetch)." >&2
    exit 2
fi

fetch_one() {
    local url=$1 fn
    fn=$(basename "$url")
    if [ -s "$fn" ]; then
        echo "== have $fn"
        return 0
    fi
    echo "== fetching $url"
    curl -fsSL --retry 3 -o "$fn.part" "$url" && mv "$fn.part" "$fn"
}

while read -r line; do
    line=${line%%#*}; line=${line## }; line=${line%% }
    [ -z "$line" ] && continue
    cat=${line%%/*}; name=${line##*/}
    if [ ! -d "$PKGSRCDIR/$cat/$name" ]; then
        echo "WARN: $cat/$name not in pkgsrc tree, skipping" >&2
        continue
    fi
    # Use bmake fetch-list to enumerate URLs deterministically.
    # If bmake isn't on PATH, fall back to scraping Makefile + distinfo.
    if command -v bmake >/dev/null 2>&1; then
        urls=$(cd "$PKGSRCDIR/$cat/$name" && \
               bmake fetch-list 2>/dev/null | \
               awk '/^[[:space:]]*\(cd / {next} /curl|wget|fetch/ {for (i=1;i<=NF;i++) if ($i ~ /^https?:\/\//) print $i}')
    else
        urls=$(awk '/^MASTER_SITES/{site=$3} /^DISTNAME/{name=$3} END{print site name}' \
               "$PKGSRCDIR/$cat/$name/Makefile" 2>/dev/null || true)
    fi
    if [ -z "$urls" ]; then
        echo "WARN: no URLs found for $cat/$name" >&2
        continue
    fi
    for u in $urls; do fetch_one "$u"; done
done < "$LIST_FILE"

echo
echo "distfiles in $DISTDIR:"
ls -la "$DISTDIR" | tail -n +2 | head -20
echo "... $(ls "$DISTDIR" | wc -l) total"
