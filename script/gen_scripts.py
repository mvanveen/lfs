#!/usr/bin/env python3
"""Generate flat pkg/prep and pkg/build shell trees from the scraped book.

This mirrors the layout used by the original LFS 9.1 port:

  pkg/prep/   one script per package run as the `lfs` user before chroot
              (LFS 12.4 chapters 5 + 6).  Scripts are designed to be
              `source`d, old-style cd in / cd out.

  pkg/build/  everything run inside the chroot (LFS 12.4 chapters 7..10)
              plus two drivers:
                  run-build.sh  -- outside chroot: mount vkfs, chroot,
                                   invoke as-chroot.sh
                  as-chroot.sh  -- inside chroot: run each package script
                                   in order via `sh name.sh`

Scripts are intentionally simple: no `set -euxo pipefail`, no pushd/popd,
just the book's commands wrapped by `cd /mnt/lfs/sources; tar xf ...;
cd <dir>; ... ; cd ..; rm -rf <dir>`.
"""
import json
import pathlib
import re
import shutil

SLUG_MAP = json.load(open('script/slug_map.json'))
SRC = pathlib.Path('script/book-html')
DST = pathlib.Path('pkg')
if DST.exists():
    shutil.rmtree(DST)
(DST/'prep').mkdir(parents=True)
(DST/'build').mkdir(parents=True)

# ----------------------------------------------------------------- ordering
# The curated order within each logical phase.  Slugs not in SLUG_MAP are
# treated as "non-package" (they're raw sequences of commands, e.g.
# creatingdirs, createfiles, changingowner).
PREP_ORDER = [
    # ch 5 - cross toolchain (into $LFS/tools)
    ('ch5-toolchain', 'binutils-pass1'),
    ('ch5-toolchain', 'gcc-pass1'),
    ('ch5-toolchain', 'linux-headers'),
    ('ch5-toolchain', 'glibc'),
    ('ch5-toolchain', 'gcc-libstdc++'),
    # ch 6 - cross-compiled temporary tools (into $LFS/usr)
    ('ch6-crosstools', 'm4'),
    ('ch6-crosstools', 'ncurses'),
    ('ch6-crosstools', 'bash'),
    ('ch6-crosstools', 'coreutils'),
    ('ch6-crosstools', 'diffutils'),
    ('ch6-crosstools', 'file'),
    ('ch6-crosstools', 'findutils'),
    ('ch6-crosstools', 'gawk'),
    ('ch6-crosstools', 'grep'),
    ('ch6-crosstools', 'gzip'),
    ('ch6-crosstools', 'make'),
    ('ch6-crosstools', 'patch'),
    ('ch6-crosstools', 'sed'),
    ('ch6-crosstools', 'tar'),
    ('ch6-crosstools', 'xz'),
    ('ch6-crosstools', 'binutils-pass2'),
    ('ch6-crosstools', 'gcc-pass2'),
]

BUILD_ORDER = [
    # ch 7 - initial filesystem inside the chroot, then additional temp tools
    ('ch7-chroot-tools', 'creatingdirs'),
    ('ch7-chroot-tools', 'createfiles'),
    ('ch7-chroot-tools', 'gettext'),
    ('ch7-chroot-tools', 'bison'),
    ('ch7-chroot-tools', 'perl'),
    ('ch7-chroot-tools', 'Python'),
    ('ch7-chroot-tools', 'texinfo'),
    ('ch7-chroot-tools', 'util-linux'),
    ('ch7-chroot-tools', 'cleanup'),
    # ch 8 - final system
    ('ch8-system', 'man-pages'),
    ('ch8-system', 'iana-etc'),
    ('ch8-system', 'glibc'),
    ('ch8-system', 'zlib'),
    ('ch8-system', 'bzip2'),
    ('ch8-system', 'xz'),
    ('ch8-system', 'lz4'),
    ('ch8-system', 'zstd'),
    ('ch8-system', 'file'),
    ('ch8-system', 'readline'),
    ('ch8-system', 'm4'),
    ('ch8-system', 'bc'),
    ('ch8-system', 'flex'),
    ('ch8-system', 'tcl'),
    ('ch8-system', 'expect'),
    ('ch8-system', 'dejagnu'),
    ('ch8-system', 'binutils'),
    ('ch8-system', 'gmp'),
    ('ch8-system', 'mpfr'),
    ('ch8-system', 'mpc'),
    ('ch8-system', 'attr'),
    ('ch8-system', 'acl'),
    ('ch8-system', 'libcap'),
    ('ch8-system', 'libxcrypt'),
    ('ch8-system', 'shadow'),
    ('ch8-system', 'gcc'),
    ('ch8-system', 'ncurses'),
    ('ch8-system', 'sed'),
    ('ch8-system', 'psmisc'),
    ('ch8-system', 'gettext'),
    ('ch8-system', 'bison'),
    ('ch8-system', 'grep'),
    ('ch8-system', 'bash'),
    ('ch8-system', 'libtool'),
    ('ch8-system', 'gdbm'),
    ('ch8-system', 'gperf'),
    ('ch8-system', 'expat'),
    ('ch8-system', 'inetutils'),
    ('ch8-system', 'less'),
    ('ch8-system', 'perl'),
    ('ch8-system', 'xml-parser'),
    ('ch8-system', 'intltool'),
    ('ch8-system', 'autoconf'),
    ('ch8-system', 'automake'),
    ('ch8-system', 'openssl'),
    ('ch8-system', 'kmod'),
    ('ch8-system', 'libelf'),
    ('ch8-system', 'libffi'),
    ('ch8-system', 'Python'),
    ('ch8-system', 'flit-core'),
    ('ch8-system', 'wheel'),
    ('ch8-system', 'setuptools'),
    ('ch8-system', 'ninja'),
    ('ch8-system', 'meson'),
    ('ch8-system', 'coreutils'),
    ('ch8-system', 'diffutils'),
    ('ch8-system', 'gawk'),
    ('ch8-system', 'findutils'),
    ('ch8-system', 'groff'),
    ('ch8-system', 'gzip'),
    ('ch8-system', 'iproute2'),
    ('ch8-system', 'kbd'),
    ('ch8-system', 'libpipeline'),
    ('ch8-system', 'make'),
    ('ch8-system', 'patch'),
    ('ch8-system', 'tar'),
    ('ch8-system', 'texinfo'),
    ('ch8-system', 'vim'),
    ('ch8-system', 'markupsafe'),
    ('ch8-system', 'jinja2'),
    ('ch8-system', 'udev'),
    ('ch8-system', 'man-db'),
    ('ch8-system', 'procps-ng'),
    ('ch8-system', 'util-linux'),
    ('ch8-system', 'e2fsprogs'),
    ('ch8-system', 'pkgconf'),
    ('ch8-system', 'sysklogd'),
    ('ch8-system', 'sysvinit'),
    # ch 9 - system configuration
    ('ch9-config', 'etcshells'),
    ('ch9-config', 'inputrc'),
    ('ch9-config', 'locale'),
    ('ch9-config', 'network'),
    ('ch9-config', 'symlinks'),
    ('ch9-config', 'usage'),
    # ch 10 - kernel + GRUB
    ('ch10-boot',  'fstab'),
    ('ch10-boot',  'kernel'),
    ('ch10-boot',  'grub'),
]

# -------------------------------------------------------------- text fixups
# Book commands that can't run unattended verbatim.
PATCHES = [
    # Book re-execs bash after rewriting /etc/passwd - inert inside a script.
    (re.compile(r'^\s*exec\s+/usr/bin/bash\s+--login\s*$', re.MULTILINE),
     '# book: exec /usr/bin/bash --login  (skipped: script driver)'),
    # Interactive kernel configuration.
    (re.compile(r'^\s*make\s+menuconfig\s*$', re.MULTILINE),
     'make defconfig   # book uses `make menuconfig`; use defconfig for unattended build'),
    # Passwd prompts.
    (re.compile(r'^\s*passwd\s+(root|tester)\s*$', re.MULTILINE),
     r'# book: passwd \1  (set out-of-band for unattended build)'),
    # Angle-bracket placeholders (<paper_size>, <locale name>, <xxx>, ...).
    (re.compile(
         r'^(.*<(?:paper_size|locale name|xxx|yyy|fff|ll|CC|charmap|'
         r'@modifiers|lfs|tz)>.*)$', re.MULTILINE),
     r'# TEMPLATE (edit before running): \1'),
]


def load_cmds(chapter, slug):
    path = SRC/chapter/f'{slug}.cmds'
    if not path.exists():
        return None
    text = path.read_text()
    # Drop the leading `# source: ...` line (we emit our own header).
    text = re.sub(r'^# source:.*\n\n?', '', text)
    for pat, rep in PATCHES:
        text = pat.sub(rep, text)
    return text.strip() + '\n'


def render(chapter, slug):
    cmds = load_cmds(chapter, slug)
    if cmds is None:
        print(f'MISSING {chapter}/{slug}')
        return None
    url = f'https://www.linuxfromscratch.org/lfs/view/stable/{chapter[:3] + chapter[3:].split("-")[0]}/{slug}.html'
    # Normalize chapter to book URL path: ch5-toolchain -> chapter05, etc.
    chap_num = re.match(r'ch(\d+)', chapter).group(1).zfill(2)
    url = f'https://www.linuxfromscratch.org/lfs/view/stable/chapter{chap_num}/{slug}.html'

    header = (
        f'# {slug}  --  {url}\n'
        f'# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061\n'
    )

    info = SLUG_MAP.get(slug)
    if not info:
        # Non-package block (raw commands; run in whatever cwd the driver picks).
        return header + cmds

    tb = info['tarball']
    d  = info['dir']
    pre  = f'cd /mnt/lfs/sources\nrm -rf {d}\ntar xf {tb}\ncd {d}\n\n'
    post = f'\ncd /mnt/lfs/sources\nrm -rf {d}\n'
    return header + pre + cmds + post


def emit(order, subdir):
    written = []
    for chapter, slug in order:
        rendered = render(chapter, slug)
        if rendered is None:
            continue
        # Flat filename.  When the same slug appears in multiple chapters
        # (Python, bison, gettext, util-linux, perl, texinfo all appear in
        # ch7 AND ch8), disambiguate the earlier (ch7) one.
        if (DST/subdir/f'{slug}.sh').exists():
            name = f'{slug}-temp.sh' if chapter == 'ch7-chroot-tools' else f'{slug}-final.sh'
        else:
            name = f'{slug}.sh'
            # For well-known ch7 temp-tool slugs that we know repeat in ch8,
            # we already emit the ch7 one first so they'll get suffixed when
            # ch8 comes around.
        (DST/subdir/name).write_text(rendered)
        written.append(name)
    return written


def main():
    prep_files  = emit(PREP_ORDER,  'prep')
    build_files = emit(BUILD_ORDER, 'build')

    # run-build.sh: outside chroot, mount vkfs and chroot into as-chroot.sh.
    (DST/'build'/'run-build.sh').write_text(r'''#!/bin/bash
# Outside chroot: mount the virtual kernel filesystems then chroot into
# $LFS and run as-chroot.sh.
set -euo pipefail

LFS=${LFS:-/mnt/lfs}

# Ch 7.2 - changing ownership of anything still owned by the lfs user.
chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools} 2>/dev/null || true
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 2>/dev/null || true ;;
esac

# Ch 7.3 - mount virtual kernel file systems.
mkdir -pv $LFS/{dev,proc,sys,run}
mountpoint -q $LFS/dev     || mount -v --bind /dev $LFS/dev
mountpoint -q $LFS/dev/pts || mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mountpoint -q $LFS/proc    || mount -vt proc proc $LFS/proc
mountpoint -q $LFS/sys     || mount -vt sysfs sysfs $LFS/sys
mountpoint -q $LFS/run     || mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mountpoint -q $LFS/dev/shm || mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

# Forward FORCE (comma-separated pkg names to re-run) into the chroot.
FORCE="${FORCE:-}"

# Ch 7.4 - enter chroot and continue.
chroot "$LFS" /usr/bin/env -i                 \
    HOME=/root                                \
    TERM="$TERM"                              \
    PS1='(lfs chroot) \u:\w\$ '               \
    PATH=/usr/bin:/usr/sbin                   \
    MAKEFLAGS="-j$(nproc)"                    \
    TESTSUITEFLAGS="-j$(nproc)"               \
    FORCE="$FORCE"                            \
    /bin/bash --login -c "bash /sources/build/as-chroot.sh"
''')

    # Shared runner: per-package stamp + logfile + resume on rerun.
    runner = r'''
# ----- resumable runner ------------------------------------------------
# Each package script is run in its own bash; on success we drop a stamp
# in $STAMP_DIR.  Reruns skip stamped packages.  Set FORCE=pkg1,pkg2 to
# re-run specific packages (or FORCE=all to wipe every stamp).
mkdir -p "$STAMP_DIR" "$LOG_DIR"

force_list=",${FORCE:-},"
if [ "${FORCE:-}" = "all" ]; then
    rm -f "$STAMP_DIR"/*
    force_list=",,"
fi

run_pkg() {
    local script="$1" name stamp log
    name=$(basename "$script" .sh)
    stamp="$STAMP_DIR/$name"
    log="$LOG_DIR/$name.log"
    if [[ "$force_list" == *",$name,"* ]]; then
        rm -f "$stamp"
    fi
    if [ -e "$stamp" ]; then
        printf '[skip]  %s\n' "$name"
        return 0
    fi
    printf '[build] %s  (log: %s)\n' "$name" "$log"
    local start=$SECONDS
    if ! bash "$script" >"$log" 2>&1; then
        printf '[FAIL]  %s  (see %s)\n' "$name" "$log" >&2
        tail -n 40 "$log" >&2 || true
        return 1
    fi
    printf '[ok]    %s  (%ds)\n' "$name" "$((SECONDS - start))"
    touch "$stamp"
}
'''.lstrip('\n')

    # as-chroot.sh: inside chroot, run every package script in order.
    lines = ['#!/bin/bash',
             '# Inside chroot: build chapters 7 (final parts), 8, 9, 10.',
             'set -euo pipefail',
             '',
             'STAMP_DIR=/sources/.done/build',
             'LOG_DIR=/sources/.log/build',
             '',
             runner,
             'cd /sources/build',
             '']
    for name in build_files:
        lines.append(f'run_pkg /sources/build/{name}')
    (DST/'build'/'as-chroot.sh').write_text('\n'.join(lines) + '\n')

    # Driver for pkg/prep/ (runs as the lfs user, outside chroot).
    lines = ['#!/bin/bash',
             '# Drive pkg/prep/*.sh in book order (runs as the lfs user).',
             'set -euo pipefail',
             '',
             'STAMP_DIR=/mnt/lfs/sources/.done/prep',
             'LOG_DIR=/mnt/lfs/sources/.log/prep',
             '',
             runner,
             '']
    for name in prep_files:
        lines.append(f'run_pkg /mnt/lfs/sources/prep/{name}')
    (DST/'prep'/'run-prep.sh').write_text('\n'.join(lines) + '\n')

    print(f'wrote {len(prep_files)} prep scripts, {len(build_files)} build scripts')


if __name__ == '__main__':
    main()
