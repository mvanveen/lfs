# pkgsrc scaffolding end-to-end test

Validates Phase 0 + 1 + 2 + 3 of `docs/pkgsrc-plan.md` by running every
driver script inside the existing LFS chroot. No fresh build required;
uses the already-validated `lfs.img` from `lfs-12.4-full-build-validated`.

## Result: ✅ Pass

| Phase | Step | Outcome |
| ----- | ---- | ------- |
| 0 | `make build-pkgs FORCE=sqlite,bootscripts` | sqlite3 + lfs-bootscripts installed; /etc/rc.d/init.d/* now populated |
| 0 | `make build-pkgs FORCE=Python-final` | rebuilt CPython; `import sqlite3` works (sqlite_version 3.50.4) |
| 0 | `make build-pkgs FORCE=locale` | `/etc/profile` now sources `/etc/profile.d/*.sh`; valid bash syntax |
| 0 | `make build-pkgs FORCE=network` | `/etc/resolv.conf` populated with public DNS instead of placeholders |
| 1 | `chroot … bash sources-partition.sh` | `/srv/sources/{lfs,blfs,distfiles,pkgsrc,pkgsrc-packages}` created; 99 LFS tarballs (585 MB) copied with MANIFEST.txt (md5 + size) |
| 2 | `chroot … bash bootstrap.sh` | pkgsrc-2025Q3 cloned (984 MB) + bootstrapped into `/opt/pkg-2025Q3` in 2m 17s; `/opt/pkg → /opt/pkg-2025Q3` symlink active |
| 3 | `chroot … bash baseline.sh` | full preboot loop: fetch → libfetch → perl → libxml2 → nghttp2 → libidn2 → curl → libarchive → sqlite3 → pkgin = 27 packages, 137 MB at /opt/pkg, 3m 30s |
| smoke | `bash -lc 'curl https://github.com'` | HTTP/2 200 (TLS via pkgsrc curl, OpenSSL 3.5.2) |

## Issues found and fixed during the test

1. **`/etc/profile` had unterminated `else` branch** — LFS book leaves
   `export LANG=<ll>_<CC>...` that the gen-scripts placeholder filter
   converts to a comment, leaving an empty `else`. Bash refuses to source.
   Fixed by replacing the placeholder line with `export LANG=C.UTF-8`
   *before* the angle-bracket rule runs (`gen_scripts.py` PATCHES).
2. **`/etc/resolv.conf` had `<placeholder>` nameservers** — same root
   cause; book's ch9 network step expects you to hand-edit. Replaced
   with `1.1.1.1` and `8.8.8.8` so the booted system has DNS.
3. **`/etc/profile` didn't source `/etc/profile.d/*.sh`** — LFS's
   `/etc/profile` is minimal. Added the loop before `# End /etc/profile`
   so `pkgsrc.sh` and `ssl-cert.sh` get loaded by login shells.
4. **No CA bundle** — OpenSSL 3.5.2 looks at `/etc/ssl/cert.pem` by
   default (OPENSSLDIR=/etc/ssl); LFS doesn't ship one. `bootstrap.sh`
   now stages Mozilla's bundle from `https://curl.se/ca/cacert.pem` and
   exports `SSL_CERT_FILE` via `/etc/profile.d/ssl-cert.sh`.
5. **pkgsrc fetch ↔ openssl circular** — `net/fetch → libfetch →
   security/openssl (Full dep) → net/fetch (Bootstrap dep)`. Fixed by
   `PKG_OPTIONS.libfetch= inet6 -openssl` in `mk.conf` so the
   bootstrap-built fetch is HTTP-only. We then pre-stage HTTPS distfiles
   via the host-side curl (see `pkgsrc/prefetch.sh`), build pkgsrc curl
   (which links system openssl from /usr because of the LFS-base
   detection), and once curl is installed `baseline.sh` writes
   `FETCH_USING= curl` into `mk.conf` so the rest of the world is HTTPS.
6. **`security/openssl`'s buildlink would still trigger pkgsrc rebuild**
   — Mitigated with `PREFER_NATIVE+= openssl` and
   `BUILDLINK_DEPMETHOD.openssl= build`.

All fixes are in commits on `wip/lfs-bootscripts-and-fixes`.

## Reproducer

```sh
cd ~/lfs
# 1. Phase 0 (rebuilds locale/network/Python-final/sqlite/bootscripts):
make upload-pkgs
make build-pkgs FORCE=sqlite,bootscripts,Python-final,locale,network

# 2. Phase 1 (sources partition, ~1 min, 585 MB copy):
make sources-partition
# (current target runs in container; for chroot use:)
ssh -p 2222 root@localhost 'cp /root/sources-partition.sh /mnt/lfs/root/ && \
  chroot /mnt/lfs bash /root/sources-partition.sh'

# 3. Pre-stage pkgsrc tree + initial distfiles (chicken/egg, one-time):
ssh -p 2222 root@localhost 'cd /tmp && \
  git clone --depth=1 --branch pkgsrc-2025Q3 \
    https://github.com/NetBSD/pkgsrc.git pkgsrc-2025Q3 && \
  mv pkgsrc-2025Q3 /mnt/lfs/srv/sources/pkgsrc/2025Q3'
# Curl deps (xz, xmlcatmgr, libxml2, nghttp2, openssl, cacert):
# fetched via host curl, see docs/pkgsrc-scaffold-test.md.

# 4. Phase 2 (~2.5 min):
ssh -p 2222 root@localhost 'cp /root/bootstrap.sh /mnt/lfs/root/ && \
  chroot /mnt/lfs bash /root/bootstrap.sh'

# 5. Phase 3 baseline (here we used a 1-line list = www/curl + pkgin):
ssh -p 2222 root@localhost 'chroot /mnt/lfs bash /root/baseline.sh'
```

## Open scaffold gaps

- The `make sources-partition`, `make pkgsrc-bootstrap`, `make pkgsrc-baseline`
  Makefile targets currently SSH to `root@localhost` (the container) but
  the actual workdir is the LFS chroot at `/mnt/lfs`. The chroot wrapper
  is hand-applied above. Polish item: change targets to chroot in
  automatically once the rootfs is no longer overlapping with the
  container's networking.
- pkgsrc tree is currently 984 MB git checkout; consider a shallow
  `archive` tarball for faster ship.
- `/srv/sources` is still on the same ext4 partition as `/`. Phase 1
  proper (separate partition + fstab) is queued for a follow-up branch.
