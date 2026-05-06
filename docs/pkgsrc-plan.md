# pkgsrc-on-LFS distribution plan

Goal: turn the LFS 12.4 base into a usable distribution by layering NetBSD's
pkgsrc on top, keeping every source artifact on a dedicated partition so the
build is fully reproducible and offline-recoverable.

## Layout

```
/                                     LFS rootfs (ext4 partition 1)
/opt/pkg            → /opt/pkg-2025Q3 symlink, what users have on PATH
/opt/pkg-2025Q3/                      pkgsrc PREFIX for this quarter
/opt/pkg-2025Q4/                      next quarter, parallel install
/var/db/pkg-2025Q3/                   PKG_DBDIR for this quarter
/etc/profile.d/pkgsrc.sh              prepends /opt/pkg/{bin,sbin} to PATH

/srv/sources/                         second partition, mounted from fstab
  lfs/                                tarballs from the LFS 12.4 build
    *.tar.{xz,gz,bz2}                 every file from $LFS/sources/
    md5sums                           verbatim copy from /home/exedev/lfs
    packages.txt                      verbatim copy
  blfs/                               hand-compiled BLFS recipes we use
    sqlite-autoconf-3500400.tar.gz    (already pulled in for python)
    <future BLFS deps>
  pkgsrc/                             pkgsrc trees, one per quarter
    2025Q3/                           git checkout of pkgsrc-2025Q3
    2025Q4/                           future
    current  → 2025Q3                 PKGSRCDIR points here
  distfiles/                          DISTDIR, shared across quarters
  pkgsrc-packages/                    PACKAGES, per quarter
    2025Q3/All/*.tgz                  built binary packages
```

Why two prefixes for pkgsrc:

- ABI breaks across pkgsrc quarterlies (perl, python ABI, library SONAMEs).
  Parallel installs let us flip `/opt/pkg` after testing, with instant
  rollback by re-flipping the symlink.
- Distfiles cache survives across quarters; binary packages don't.

## Three coexisting prefixes

| prefix      | owner            | contents                                          |
| ----------- | ---------------- | ------------------------------------------------- |
| `/usr`      | LFS              | base system: glibc, gcc, coreutils, bash, vim, .. |
| `/opt/pkg`  | pkgsrc (NetBSD)  | userland packages installed via `bmake` / `pkgin` |
| `/usr/local`| BLFS / hand-roll | anything we compile ourselves outside pkgsrc      |

BSD tools that collide with GNU equivalents get the `b` prefix
(`/opt/pkg/bin/bmake`, `bsdtar`, `bsdinstall`, ...). pkgsrc bootstrap does
this automatically; we don't have to configure it.

## Phasing

1. **Phase 0** (done on this branch): wire `lfs-bootscripts` into the build,
   add sqlite before Python so `_sqlite3` builds.
2. **Phase 1**: sources partition. New raw image partitioned + ext4'd, fstab
   entry, `make sources-partition` target that copies `$LFS/sources/*` and
   the build manifests into `/srv/sources/lfs/`.
3. **Phase 2**: pkgsrc bootstrap driver. Clone the quarterly tree into
   `/srv/sources/pkgsrc/<Q>/`, run `bootstrap --prefix=/opt/pkg-<Q>`, install
   `pkgtools/pkgin` and `pkgtools/digest`. Drop `/etc/profile.d/pkgsrc.sh`.
4. **Phase 3**: baseline package set (`pkg/pkgsrc-baseline.list`): bash, zsh,
   git, tmux, vim, htop, openssh, curl, wget, dhcpcd, python313, etc.
5. **Phase 4**: BLFS bridges as needed. Each lives in `pkg/blfs/<name>.sh`
   following the BLFS book; tarballs go in `/srv/sources/blfs/`.
6. **Phase 5**: real bootable image. Run `grub-install`, produce a qcow2
   that boots without `-kernel`. Two-partition image (rootfs + sources).

## pkgsrc bootstrap invocation

```sh
Q=2025Q3
cd /srv/sources/pkgsrc/$Q/bootstrap
./bootstrap \
    --prefix=/opt/pkg-$Q \
    --pkgdbdir=/var/db/pkg-$Q \
    --varbase=/var \
    --sysconfdir=/opt/pkg-$Q/etc \
    --make-jobs=$(nproc) \
    --unprivileged   # not strictly needed; we run as root
```

`mk.conf` overrides we want, dropped at `/opt/pkg-$Q/etc/mk.conf`:

```
DISTDIR=          /srv/sources/distfiles
PACKAGES=         /srv/sources/pkgsrc-packages/2025Q3
WRKOBJDIR=        /var/tmp/pkgsrc-build
MAKE_JOBS=        2
FETCH_USING=      curl
ALLOW_VULNERABLE_PACKAGES= yes      # pragmatic; pkgin will still warn
PKG_DEFAULT_OPTIONS+= -inet6        # adjust to taste
```

Quarterly switch (future):

```
make pkgsrc-switch QUARTER=2025Q4
  → git clone -b pkgsrc-2025Q4 … /srv/sources/pkgsrc/2025Q4
  → bootstrap into /opt/pkg-2025Q4
  → pkgin -y install <baseline list>
  → ln -sfn /opt/pkg-2025Q4 /opt/pkg
  → ln -sfn 2025Q4 /srv/sources/pkgsrc/current
```

## Source-completeness invariant

For every binary on the resulting system, the source must be present under
`/srv/sources/`:

- LFS base: `/srv/sources/lfs/` holds the same tarballs that were in
  `$LFS/sources/` plus `md5sums` and `packages.txt`. Manifest at
  `/srv/sources/lfs/MANIFEST.txt` lists package, version, tarball, md5.
- pkgsrc: `/srv/sources/distfiles/` holds every distfile pkgsrc ever fetched,
  and `/srv/sources/pkgsrc/<Q>/` is the recipe tree that knows how to build
  them. `pkgin` will reuse the cache.
- BLFS / hand-rolled: each driver script copies its tarball into
  `/srv/sources/blfs/` before extracting into a build dir.

A `make audit-sources` target (Phase 5) will diff installed packages against
the sources tree and fail the build if anything is missing.
