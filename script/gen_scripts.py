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

# Canonical book order (scraped from
# https://www.linuxfromscratch.org/lfs/view/stable/chapter{07,08,09,10}/
# index pages).  Edit by re-scraping when retargeting future LFS releases
# rather than hand-editing.
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
    # ch 8 - final system (canonical book order)
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
    ('ch8-system', 'pkgconf'),
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
    ('ch8-system', 'libelf'),
    ('ch8-system', 'libffi'),
    ('ch8-system', 'Python'),
    ('ch8-system', 'flit-core'),
    ('ch8-system', 'packaging'),
    ('ch8-system', 'wheel'),
    ('ch8-system', 'setuptools'),
    ('ch8-system', 'ninja'),
    ('ch8-system', 'meson'),
    ('ch8-system', 'kmod'),
    ('ch8-system', 'coreutils'),
    ('ch8-system', 'diffutils'),
    ('ch8-system', 'gawk'),
    ('ch8-system', 'findutils'),
    ('ch8-system', 'groff'),
    # ch8 grub builds the binaries; ch10 grub does grub-install + grub.cfg.
    ('ch8-system', 'grub'),
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
    # bash's test driver runs `make tests` inside an expect heredoc:
    #   LC_ALL=C.UTF-8 su -s /usr/bin/expect tester << "EOF"
    #   set timeout -1
    #   spawn make tests
    #   ...
    #   EOF
    # Gate the whole heredoc on RUN_TESTS=1 (Docker containers often
    # don't have enough ptys for `make tests` to run anyway).
    (re.compile(
        r'^(?P<indent>[ \t]*)'
        r'(?P<block>'
        r'LC_ALL=\S+\s+su\s+-s\s+/usr/bin/expect\s+tester\s*<<\s*"EOF"\n'
        r'(?:.*\n)*?'
        r'EOF)\n',
        re.MULTILINE),
     lambda m: (
        f"{m.group('indent')}if [ \"${{RUN_TESTS:-0}}\" = 1 ]; then\n"
        f"{m.group(0)[:-1]}\n"  # drop trailing \n then re-add
        f"{m.group('indent')}else\n"
        f"{m.group('indent')}  echo 'skip tests (RUN_TESTS=0): expect heredoc'\n"
        f"{m.group('indent')}fi\n"
     )),
    # ncurses builds .so.X.Y where X.Y is the runtime version of the
    # tarball (book hardcodes 6.5 from its dated snapshot).  We may have
    # substituted a newer ncurses (e.g. 6.6) which produces .so.6.6 -
    # discover the actual filename at runtime.
    (re.compile(r'(install\s+-vm755\s+)dest/usr/lib/libncursesw\.so\.6\.\d+(\s+/usr/lib)'),
     r'\1"$(echo dest/usr/lib/libncursesw.so.6.*)"\2'),
    (re.compile(r'(rm\s+-v\s+)\s*dest/usr/lib/libncursesw\.so\.6\.\d+'),
     r'\1"$(echo dest/usr/lib/libncursesw.so.6.*)"'),
    # Same idea for the doc dir reference (was ncurses-6.5-20250809).
    (re.compile(r'/usr/share/doc/ncurses-6\.\d+(?:-\d+)?'),
     r'/usr/share/doc/ncurses'),
    # The book assumes /boot is a separate partition; our single-partition
    # loopback layout has it as a plain directory.  Drop `mount /boot` and
    # change `cp -iv` (-i prompts for overwrite) to `cp -fv` so kernel +
    # grub installs are non-interactive.
    (re.compile(r'^\s*mount\s+/boot\s*$', re.MULTILINE),
     'mkdir -pv /boot   # book mounts a separate /boot here'),
    (re.compile(r'\bcp\s+-iv\b'), 'cp -fv'),
    # ch10 grub-final's `grub-mkrescue --output=...` needs xorriso/mtools
    # the LFS image doesn't have; same with `xorriso -as cdrecord` and
    # `grub-install /dev/sda` which targets a host disk we don't own.
    # These are bootloader-install steps the user runs manually post-build.
    (re.compile(r'^\s*grub-mkrescue\s[^\n]*$', re.MULTILINE),
     '# book: grub-mkrescue ...  (run manually post-build)'),
    (re.compile(r'^\s*xorriso\s+-as\s+cdrecord[^\n]*$', re.MULTILINE),
     '# book: xorriso -as cdrecord ...  (run manually post-build)'),
    (re.compile(r'^\s*grub-install\s+/dev/sda\s*$', re.MULTILINE),
     '# book: grub-install /dev/sda  (run manually post-build with real device)\n'
     'mkdir -pv /boot/grub'),
    # ch9 symlinks runs udevadm probes (`udevadm test /sys/block/hdd`,
    # `udevadm info -a -p /sys/class/video4linux/video0`) and seds the
    # 83-cdrom-symlinks.rules file for the user to eyeball; they fail
    # when the devices / files don't exist (e.g. inside a container).
    (re.compile(r'^(\s*)(udevadm\s+(?:test|info)\s[^\n]+)$', re.MULTILINE),
     r'\1\2 || :  # advisory; fails when the device is absent'),
    # The book's symlinks.html sed targets /etc/udev/rules.d/83-cdrom-symlinks.rules
    # which only exists if a prior install populated it.  Match the
    # multi-line form (sed ... \\\n  -i path) and append || :.
    (re.compile(
        r'^(\s*sed\s[^\n]*\\\n[^\n]*-i\s+/etc/udev/rules\.d/83-cdrom-symlinks\.rules)\s*$',
        re.MULTILINE),
     r'\1 || :  # advisory; rules file may not exist'),
    # util-linux's `bash tests/run.sh ...` requires the test programs to
    # have been compiled; gate on RUN_TESTS so it's optional.
    (re.compile(r'^(?P<indent>[ \t]*)(?P<cmd>bash\s+tests/run\.sh[^\n]*)$', re.MULTILINE),
     r'\g<indent>if [ "${RUN_TESTS:-0}" = 1 ]; then \g<cmd>; else echo "skip tests/run.sh (RUN_TESTS=0)"; fi'),
    # `ln -sv` -> `ln -sfv` so a partial / re-run install doesn't fail on
    # symlinks that already exist from a previous attempt.  Idempotent.
    (re.compile(r'\bln\s+-sv\b'), 'ln -sfv'),
    # vim's interactive `vim -c ':options'` smoke test -- redirect stdin
    # so it returns immediately, and ignore the inevitable error.
    (re.compile(r"^\s*vim\s+-c\s+':options'\s*$", re.MULTILINE),
     '# book: vim -c \':options\'  (interactive; skipped)'),
    # groff's `PAGE=<paper_size> ./configure ...` -- pick A4 unconditionally.
    (re.compile(r'^(\s*)PAGE=<paper_size>(\s+\./configure[^\n]*)$', re.MULTILINE),
     r'\1PAGE=A4\2'),
    # gmp's `ABI=32 ./configure ...` is x86-only documentation, not a real
    # command (`...` is literal); kill it so x86_64 builds don't choke.
    (re.compile(r'^\s*ABI=32\s+\./configure\s+\.\.\.\s*$', re.MULTILINE),
     '# book: `ABI=32 ./configure ...`  (x86-only; skipped on x86_64)'),
    # tzselect is interactive (waits on stdin for a continent number).
    # Pick UTC unconditionally; users can override post-install.  Also
    # collapses the book's `ln -sfv /usr/share/zoneinfo/<xxx> /etc/localtime`
    # into the same UTC choice (must run *before* the <xxx> placeholder
    # rule below, which would otherwise comment that line out).
    (re.compile(r'^\s*tzselect\s*$', re.MULTILINE),
     '# book: tzselect  (interactive - default to UTC)\n'
     'ln -sfv /usr/share/zoneinfo/UTC /etc/localtime'),
    (re.compile(r'^\s*ln\s+-sfv\s+/usr/share/zoneinfo/<xxx>\s+/etc/localtime\s*$', re.MULTILINE),
     '# (UTC symlink already created in lieu of tzselect)'),
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


def render(chapter, slug, sources_dir='/mnt/lfs/sources'):
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
        f'set -e\n'
    )

    # Targeted `|| :` on verification-only grep / readelf lines so the
    # book's eyeball checks (e.g. `readelf -l a.out | grep ': /lib'`)
    # don't take down the build when they happen to match nothing.
    # We still keep strict mode for everything else -- crucially for
    # essential post-install commands like bash's `ln -sv bash $LFS/bin/sh`.
    cmds = _relax_verification_lines(cmds)

    # `make check` is advisory in the book (some failures are documented
    # as acceptable on Docker / overlayfs).  Gate on $RUN_TESTS so slow
    # hosts can skip them entirely; never let a check failure abort.
    cmds = _gate_make_check(cmds)

    info = SLUG_MAP.get(slug)
    if not info:
        # Non-package block (raw commands; run in whatever cwd the driver picks).
        return header + cmds

    tb = info['tarball']
    d  = info['dir']
    pre  = f'cd {sources_dir}\nrm -rf {d}\ntar xf {tb}\ncd {d}\n\n'
    post = f'\ncd {sources_dir}\nrm -rf {d}\n'
    return header + pre + cmds + post


# Lines that start a pipeline with `grep`, `readelf`, or `find` and do
# no assignment / redirection are the book's eyeball verification lines.
# Append `|| :` so they can't take down `set -e`.
# Lines that are pure book-side eyeball checks (no side effects beyond
# stdout): grep, readelf, find, awk-on-a-log, head/tail/cat-on-a-log.
_VERIFY_RE = re.compile(
    r'^(?P<indent>[ \t]*)(?P<cmd>(grep|readelf|find|awk|head|tail|cat)\b[^\n]*?)$',
    re.MULTILINE,
)

def _relax_verification_lines(cmds: str) -> str:
    def repl(m):
        line = m.group(0)
        # Skip lines that already handle their own failure mode, or that
        # write to a file (so we don't mask real install-output errors).
        # `;` and `>` only count when they're outside single/double quotes.
        bare = re.sub(r"'[^']*'|\"[^\"]*\"", '', line)
        if re.search(r'(?:&&|\|\||(?<!\d)>(?!\d))', bare):
            return line
        return line + ' || :'
    return _VERIFY_RE.sub(repl, cmds)


# A `make check` / `make test` invocation, optionally wrapped in
# `su <user> -c "..."`, possibly continued onto the next line with a
# trailing backslash, possibly followed by a redirection line.
_CHECK_RE = re.compile(
    r'^(?P<indent>[ \t]*)'
    r'(?P<line>'
    # `su <user> -c "... make ... check ..."`, gobbling any backslash
    # continuations onto follow-on lines (e.g. `\< /dev/null \`).
    # `[ \t]*\\\n[^\n]*` matches `<sp/tab><backslash><newline><line>`,
    # repeated for every continuation; the leading whitespace lets us
    # accept lines like `... "check" \` (note space before backslash).
    r'(?:su\s+\S+\s+-c\s+"[^"]*\bmake\b[^"]*\b(?:check|test)\b[^"]*"'
    r'(?:[ \t]*\\\n[^\n]*)*)'
    r'|'
    # Bare `make [flags] check`, optionally with leading env-var assignments
    # like `HARNESS_JOBS=$(nproc) make test` (openssl) or
    # `LC_ALL=C ... make check` (perl-final).
    r'(?:(?:[A-Za-z_][A-Za-z0-9_]*=\S+\s+)*make(?:\s+-[^\s]+)*\s+(?:check|test)\b[^\n]*)'
    r')\s*$',
    re.MULTILINE,
)

def _gate_make_check(cmds: str) -> str:
    """Wrap `make check` / `make test` lines so they:
         - run only when RUN_TESTS=1
         - never abort the build on failure (book treats them as advisory).
       Also handles `su tester -c "... make ... check ..."` wrappers and
       backslash-continuation onto follow-on lines."""
    def repl(m):
        indent = m.group('indent')
        # Take the matched block verbatim, drop any trailing backslash so
        # we can append `|| echo ...` cleanly.
        body = m.group(0)[len(indent):].rstrip()
        if body.endswith('\\'):
            body = body[:-1].rstrip()
        # Drop any internal blank lines (they'd break `\` continuation).
        body_lines = [l for l in body.split('\n') if l.strip()]
        body_indented = '\n'.join(f'{indent}  {l}' for l in body_lines)
        return (
            f'{indent}if [ "${{RUN_TESTS:-0}}" = 1 ]; then\n'
            f'{body_indented} \\\n'
            f'{indent}    || echo "WARN: tests failed (advisory)"\n'
            f'{indent}else\n'
            f'{indent}  echo "skip tests (RUN_TESTS=0)"\n'
            f'{indent}fi'
        )
    return _CHECK_RE.sub(repl, cmds)


def emit(order, subdir):
    # Chapter 5 + 6 run on the host as lfs; the target lives under /mnt/lfs.
    # Chapters 7 + 8 + 9 + 10 run inside the chroot where it's /sources.
    sources_dir = '/mnt/lfs/sources' if subdir == 'prep' else '/sources'
    written = []
    for chapter, slug in order:
        rendered = render(chapter, slug, sources_dir=sources_dir)
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

# Forward FORCE (comma-separated pkg names to re-run) and RUN_TESTS
# (1 to run `make check` / `make test`) into the chroot.
FORCE="${FORCE:-}"
RUN_TESTS="${RUN_TESTS:-0}"

# Ch 7.4 - enter chroot and continue.
chroot "$LFS" /usr/bin/env -i                 \
    HOME=/root                                \
    TERM="$TERM"                              \
    PS1='(lfs chroot) \u:\w\$ '               \
    PATH=/usr/bin:/usr/sbin                   \
    MAKEFLAGS="-j$(nproc)"                    \
    TESTSUITEFLAGS="-j$(nproc)"               \
    FORCE="$FORCE"                            \
    RUN_TESTS="$RUN_TESTS"                    \
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
