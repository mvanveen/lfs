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

# ----- 1. fetch / unpack the tree ---------------------------------------
# Three sources, in priority order:
#   a. tree already present at $PKGSRCDIR  (idempotent re-run)
#   b. tarball at /srv/sources/pkgsrc/$QUARTER.tar.gz  (offline / pre-staged)
#   c. `git clone` (requires BLFS git+curl already installed)
if [ -d "$PKGSRCDIR/bootstrap" ]; then
    echo "==> pkgsrc tree already present at $PKGSRCDIR"
elif [ -f "$SRV/pkgsrc/$QUARTER.tar.gz" ]; then
    echo "==> extracting $SRV/pkgsrc/$QUARTER.tar.gz into $PKGSRCDIR"
    mkdir -p "$PKGSRCDIR"
    tar -xzf "$SRV/pkgsrc/$QUARTER.tar.gz" -C "$PKGSRCDIR" --strip-components=1
elif command -v git >/dev/null 2>&1; then
    echo "==> cloning $BRANCH into $PKGSRCDIR"
    git clone --depth=1 --branch "$BRANCH" \
        https://github.com/NetBSD/pkgsrc.git "$PKGSRCDIR"
else
    echo "ERROR: no pkgsrc tree at $PKGSRCDIR, no tarball at $SRV/pkgsrc/$QUARTER.tar.gz, and git not available." >&2
    echo "Install BLFS git+curl first, or pre-stage the pkgsrc tarball." >&2
    exit 2
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
# FETCH_USING left to pkgsrc's auto-detection so the bootstrap-built
# bsdfetch is used until we install www/curl from pkgsrc.
ALLOW_VULNERABLE_PACKAGES= yes
SKIP_LICENSE_CHECK=      yes
PKGSRC_RUN_TEST=         no
# Use system (LFS) openssl wherever pkgsrc detects it (libssh2, curl, ...).
# We disable the openssl OPTION on libfetch specifically because pkgsrc's
# bootstrap fetch chain is fetch -> libfetch -> security/openssl, and
# security/openssl bootstrap-depends on fetch, creating a cycle. Without
# the openssl option, libfetch builds with HTTP-only, which is fine
# because we pre-stage HTTPS distfiles via the host into DISTDIR.
PKG_OPTIONS.libfetch=    inet6
PREFER_NATIVE+=          openssl
BUILDLINK_DEPMETHOD.openssl=  build

# ---- per-package MAKE_JOBS overrides -----------------------------------
# GNU bash 5.3's builtins/Makefile.in has a parallel-make race where one
# rule does 'rm -f hash.c' (and other generated .c files) before mkbuiltins
# regenerates them, while another rule reads them. With -j>=2 you hit:
#   cc1: fatal error: hash.c: No such file or directory
# Force single-job for shells/bash until upstream fixes it. Tracking:
# Fossil ticket 9dc35fb08c (https://waltz-tare.exe.xyz/tktview/9dc35fb08c).
.if !empty(PKGPATH:Mshells/bash)
MAKE_JOBS_SAFE=          no
.endif
EOF
fi

# ----- 4. activate /opt/pkg symlink -------------------------------------
ln -sfn "$PREFIX" /opt/pkg
ln -sfn "$PKGDB"  /var/db/pkg-current

# ----- 5. PATH for new logins -------------------------------------------
mkdir -p /etc/profile.d
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

# OpenSSL on a fresh LFS has no CA bundle; without one, https:// fetches
# fail with "unable to get local issuer certificate". Stage the Mozilla
# bundle (curated by curl.se) and point OpenSSL at it via env vars.
if [ ! -s /etc/ssl/certs/ca-certificates.crt ]; then
    mkdir -p /etc/ssl/certs
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --retry 3 -o /etc/ssl/certs/ca-certificates.crt \
            https://curl.se/ca/cacert.pem || true
    fi
fi
if [ ! -e /etc/profile.d/ssl-cert.sh ]; then
    cat > /etc/profile.d/ssl-cert.sh <<'CERTPROFILE'
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
CERTPROFILE
    chmod 0644 /etc/profile.d/ssl-cert.sh
fi

# ----- 6. pkgtools/pkgin -------------------------------------------------
# pkgin needs a working fetch tool to download its build dependencies
# (curl, libfetch's deps, ...). On a fresh LFS base we have none, so we
# defer pkgin to baseline.sh, which builds www/curl first.
export PATH=$PREFIX/sbin:$PREFIX/bin:$PATH

echo
echo "pkgsrc $QUARTER bootstrapped into $PREFIX"
echo "  PATH:        /opt/pkg/{sbin,bin}"
echo "  pkgdb:       $PKGDB"
echo "  distfiles:   $DISTDIR"
echo "  binpkgs:     $PACKAGES"
echo "  recipes:     $PKGSRCDIR  (also $SRV/pkgsrc/current)"
echo
echo "Next: bash pkgsrc/baseline.sh    # build a usable userland"
