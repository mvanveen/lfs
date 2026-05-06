#!/bin/bash
# Build the /srv/sources partition layout inside the chroot / running
# system.  Idempotent: rerunning just refreshes the manifests.
#
# Source-completeness invariant: every tarball used by the LFS base build
# (chapters 5-10) is copied to /srv/sources/lfs/, with a MANIFEST.txt that
# pairs each tarball with its md5 from /sources/md5sums.  pkgsrc distfiles
# and BLFS tarballs land alongside under /srv/sources/{distfiles,blfs}/.
#
# This script is run in two contexts:
#   1. inside the LFS build chroot, before unmount, to seed /srv/sources
#      from /sources (which will become $LFS/sources on the host).
#   2. on the booted system, to refresh manifests after pkgsrc adds files.

set -euo pipefail

SRV=${SRV:-/srv/sources}
LFS_SRC=${LFS_SRC:-/sources}

mkdir -p "$SRV"/{lfs,blfs,distfiles,pkgsrc-packages}
mkdir -p "$SRV"/pkgsrc

# ----- copy LFS tarballs -------------------------------------------------
if [ -d "$LFS_SRC" ]; then
    # Only the actual source archives + the manifests.  Skip the build
    # driver dirs (.done, .log, prep, build) and any extracted package
    # dirs that resume left behind.
    find "$LFS_SRC" -maxdepth 1 -type f \
         \( -name '*.tar.*' -o -name '*.tgz' -o -name '*.zip' \
         -o -name '*.patch' -o -name 'md5sums' -o -name 'packages.txt' \
         \) -print0 \
      | xargs -0 -I {} cp -u -- {} "$SRV/lfs/"
fi

# ----- write a manifest --------------------------------------------------
{
    echo "# /srv/sources/lfs/MANIFEST.txt"
    echo "# generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "# columns: md5  filename  size_bytes"
    cd "$SRV/lfs"
    shopt -s nullglob
    for f in *.tar.* *.tgz *.zip; do
        [ -f "$f" ] || continue
        printf '%s  %s  %d\n' "$(md5sum "$f" | awk '{print $1}')" \
                                "$f" \
                                "$(stat -c%s "$f")"
    done | sort -k2
} > "$SRV/lfs/MANIFEST.txt" 2>/dev/null || true

# ----- README ------------------------------------------------------------
cat > "$SRV/README" <<'README'
/srv/sources -- complete source archive for this distribution.

  lfs/                LFS 12.4 base-build tarballs + md5sums + packages.txt
  blfs/               BLFS recipes we hand-compile (sqlite, ...)
  pkgsrc/             NetBSD pkgsrc trees, one per quarter
    2025Q3/           git checkout of pkgsrc-2025Q3 branch
    current  -> 2025Q3 (the one /opt/pkg was bootstrapped from)
  distfiles/          DISTDIR for pkgsrc, shared across quarters
  pkgsrc-packages/    PACKAGES tree, per-quarter binary packages

Every binary installed on this system has source under this tree.
Run `make audit-sources` at the LFS repo root to verify.
README

echo "sources partition seeded at $SRV"
ls -la "$SRV"
