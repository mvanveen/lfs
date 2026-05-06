#!/bin/bash
# Bootstrap pkgsrc on top of LFS.  Idempotent re-runs are safe (skips
# bootstrap if /opt/pkg-$Q already has bin/bmake).
#
# Quarterly-versioned: prefix is /opt/pkg-<QUARTER>, with /opt/pkg as a
# symlink so users see a stable PATH.
#
# Run on the booted LFS system (or in chroot) AFTER /srv/sources is
# mounted.

set -euo pipefail

QUARTER=${QUARTER:-2025Q3}
BRANCH=${BRANCH:-pkgsrc-$QUARTER}
PREFIX=/opt/pkg-$QUARTER
PKGDB=/var/db/pkg-$QUARTER
SRV=${SRV:-/srv/sources}
PKGSRCDIR=$SRV/pkgsrc/$QUARTER
DISTDIR=$SRV/distfiles
PACKAGES=$SRV/pkgsrc-packages/$QUARTER
JOBS=${JOBS:-$(nproc)}

mkdir -p "$DISTDIR" "$PACKAGES" "$SRV/pkgsrc"

# ----- 1. fetch the tree -------------------------------------------------
if [ ! -d "$PKGSRCDIR/.git" ] && [ ! -f "$PKGSRCDIR/Packages.txt" ]; then
    echo "==> cloning $BRANCH into $PKGSRCDIR"
    git clone --depth=1 --branch "$BRANCH" \
        https://github.com/NetBSD/pkgsrc.git "$PKGSRCDIR"
else
    echo "==> pkgsrc tree already present at $PKGSRCDIR"
fi

# Track 'current' symlink so PKGSRCDIR=$SRV/pkgsrc/current works.
ln -sfn "$QUARTER" "$SRV/pkgsrc/current"

# ----- 2. bootstrap ------------------------------------------------------
if [ -x "$PREFIX/bin/bmake" ]; then
    echo "==> $PREFIX already bootstrapped (bmake present); skipping"
else
    echo "==> bootstrapping pkgsrc into $PREFIX (this takes a while)"
    cd "$PKGSRCDIR/bootstrap"
    ./bootstrap \
        --prefix "$PREFIX" \
        --pkgdbdir "$PKGDB" \
        --varbase /var \
        --sysconfdir "$PREFIX/etc" \
        --make-jobs "$JOBS" \
        --workdir "/var/tmp/pkgsrc-bootstrap-$QUARTER"
fi

# ----- 3. mk.conf overrides ---------------------------------------------
MK=$PREFIX/etc/mk.conf
if ! grep -q '# managed by pkgsrc/bootstrap.sh' "$MK" 2>/dev/null; then
    echo "==> writing $MK"
    cat >> "$MK" <<EOF

# managed by pkgsrc/bootstrap.sh
DISTDIR=                 $DISTDIR
PACKAGES=                $PACKAGES
WRKOBJDIR=               /var/tmp/pkgsrc-build
MAKE_JOBS=               $JOBS
FETCH_USING=             curl
ALLOW_VULNERABLE_PACKAGES= yes
SKIP_LICENSE_CHECK=      yes
PKGSRC_RUN_TEST=         no
EOF
fi

# ----- 4. activate /opt/pkg symlink -------------------------------------
ln -sfn "$PREFIX" /opt/pkg
ln -sfn "$PKGDB"  /var/db/pkg-current

# ----- 5. PATH for new logins -------------------------------------------
cat > /etc/profile.d/pkgsrc.sh <<'PROFILE'
# Prepend pkgsrc prefix to PATH and MANPATH for all users.
if [ -d /opt/pkg/bin ]; then
    PATH=/opt/pkg/sbin:/opt/pkg/bin:$PATH
    export PATH
fi
if [ -d /opt/pkg/man ]; then
    MANPATH=/opt/pkg/man:${MANPATH:-}
    export MANPATH
fi
PROFILE
chmod 0644 /etc/profile.d/pkgsrc.sh

# ----- 6. install pkgin so binary upgrades work --------------------------
export PATH=$PREFIX/sbin:$PREFIX/bin:$PATH
if ! command -v pkgin >/dev/null 2>&1; then
    echo "==> building pkgtools/pkgin (binary package management)"
    cd "$PKGSRCDIR/pkgtools/pkgin"
    bmake install clean clean-depends
fi

echo
echo "pkgsrc $QUARTER bootstrapped into $PREFIX"
echo "  PATH:        /opt/pkg/{sbin,bin}"
echo "  pkgdb:       $PKGDB"
echo "  distfiles:   $DISTDIR"
echo "  binpkgs:     $PACKAGES"
echo "  recipes:     $PKGSRCDIR  (also $SRV/pkgsrc/current)"
echo
echo "Next: bash pkgsrc/baseline.sh    # build a usable userland"
