Linux From Scratch
==================

Automated build of **[Linux From Scratch 12.4 (SysV)][lfs]** inside a
Dockerized Ubuntu 24.04 host.

[lfs]: https://www.linuxfromscratch.org/lfs/view/stable/

### Layout

```
Dockerfile             # ubuntu:24.04 build host
Makefile               # end-to-end driver on the host side
packages.txt           # book's wget-list-sysv
md5sums                # book's md5sums
script/
  mkext4.sh            # partition + format + mount the loopback image
  stage0.sh            # create the `lfs` user, $LFS/{sources,tools}, env
  stage1.sh            # as lfs: driver for pkg/prep (ch 5 + 6)
  gen_scripts.py       # regenerate pkg/ from scraped book pages
  extract_book.py      # scrape <pre class="userinput"> from the book
  book-html/           # cached raw snippets (so gen is offline)
pkg/
  prep/                # cross toolchain + cross-compiled temp tools
    *.sh               # one per package, run as the lfs user
    run-prep.sh        # drives them in book order
  build/               # final system, system config, kernel + GRUB
    *.sh               # one per package, run inside chroot
    as-chroot.sh       # inside chroot: runs every build/*.sh in order
    run-build.sh       # outside chroot: mounts vkfs, chroots, -> as-chroot.sh
```

### Build flow

`make all` chains the following targets:

| target       | runs                                                 |
|--------------|------------------------------------------------------|
| docker-build | build the Ubuntu 24.04 LFS-host image                |
| docker-run   | start the container (privileged; sshd on :2222)     |
| mkimg        | create/partition/format a sparse loopback image, mount at /mnt/lfs |
| prep-host    | create the `lfs` user and `$LFS/{sources,tools}`     |
| dl-sources   | `wget -i packages.txt` into /mnt/lfs/sources         |
| upload-pkgs  | bulk-copy `pkg/prep` and `pkg/build` into /mnt/lfs/sources |
| prep-pkgs    | (lfs user) run `pkg/prep/run-prep.sh` — chapters 5+6 |
| build-pkgs   | (root)     run `pkg/build/run-build.sh` — chapters 7–10 |

Individual targets are re-runnable.  `ssh` / `ssh-lfs` give interactive
sessions into the container as root / lfs, which is handy for poking at a
failed build.

### Resumable builds

`run-prep.sh` and `as-chroot.sh` drop a stamp in `/mnt/lfs/sources/.done/`
after each successful package, and a per-package log in
`/mnt/lfs/sources/.log/`.  Re-running `make prep-pkgs` / `make build-pkgs`
skips anything already stamped, so a failed build resumes where it
stopped.

| command                                   | effect                                     |
|-------------------------------------------|--------------------------------------------|
| `make status`                             | list stamped (completed) packages          |
| `make logs`                               | list per-package logs by recency           |
| `make build-pkgs FORCE=gcc,glibc`         | re-run those packages even if stamped      |
| `make build-pkgs FORCE=all`               | wipe stamps, rebuild everything            |
| `make reset-stamps`                       | same, without kicking off a build          |

`upload-pkgs` uses `rsync` and leaves `.done/` and `.log/` in place, so
edits to a package script followed by `make upload-pkgs build-pkgs
FORCE=<pkg>` is the standard edit-rerun loop.

### Regenerating the package scripts

The scripts under `pkg/` are generated directly from the book's
`<pre class="userinput">` blocks.  To retarget a future LFS release:

```bash
python3 script/extract_book.py script/book-html   # rescrape the book
# Update packages.txt + md5sums from the new book.
# Edit script/slug_map.json if tarball filenames/dirs changed.
python3 script/gen_scripts.py                     # regenerate pkg/prep + pkg/build
```

### Requirements

Host: Docker (privileged containers, so loop devices work) and `make`.
The image pulls `https://github.com/mvanveen.keys` for SSH auth — change
that URL in the Dockerfile if you're not me.

### Lint

```bash
make lint
```

runs `shellcheck -S warning` over every shell script, `hadolint` on the
Dockerfile, `bash -n` for syntax, and `py_compile` on the generators.

## Distribution layer (pkgsrc on top of LFS)

The LFS base build above gives a self-hosting C/POSIX system. To turn it
into a usable distribution, we layer NetBSD's pkgsrc on top, keeping all
source artifacts on a dedicated `/srv/sources` partition.

See [`docs/pkgsrc-plan.md`](docs/pkgsrc-plan.md) for the full design, and
[`docs/qemu-boot-test.md`](docs/qemu-boot-test.md) for the boot-validation
recipe.

Three-prefix layout:

| prefix      | owner            |
| ----------- | ---------------- |
| `/usr`      | LFS (glibc, gcc, coreutils, bash, vim, ...) |
| `/opt/pkg`  | pkgsrc (`bmake` / `pkgin`-managed packages) |
| `/usr/local`| BLFS / hand-roll |

pkgsrc is quarterly-versioned: prefix `/opt/pkg-2025Q3`, with `/opt/pkg`
as a symlink so PATH is stable across upgrades. Distfiles cache lives at
`/srv/sources/distfiles` and is shared across quarterlies.

```bash
make sources-partition          # seed /srv/sources/lfs from $LFS/sources
make pkgsrc-bootstrap            # clone tree, ./bootstrap into /opt/pkg-2025Q3
make pkgsrc-baseline             # build pkg/pkgsrc-baseline.list
```
