import os, json, pathlib, re, shutil

m = json.load(open('script/slug_map.json'))
SRC = pathlib.Path('script/book-html')
DST = pathlib.Path('pkg')
if DST.exists(): shutil.rmtree(DST)

# Slugs that are NOT package builds (no tarball extraction)
NON_PKG = {
    'introduction','kernfs','chroot','changingowner','cleanup',
    'createfiles','creatingdirs','aboutdebug','stripping','pkgmgt',
    'abouttestsuites','etcshells','inputrc','locale','network',
    'symlinks','usage','fstab',
}
# Some 'packages' like Python page appears in ch7 AND ch8. slug 'Python' ok.

# Order file per chapter - curated list from the LFS book TOC
ORDER = {
    'ch5-toolchain': ['binutils-pass1','gcc-pass1','linux-headers','glibc','gcc-libstdc++'],
    'ch6-crosstools': ['m4','ncurses','bash','coreutils','diffutils','file','findutils','gawk','grep','gzip','make','patch','sed','tar','xz','binutils-pass2','gcc-pass2'],
    'ch7-chroot-tools': ['gettext','bison','perl','Python','texinfo','util-linux'],
    'ch8-system': [
        'man-pages','iana-etc','glibc','zlib','bzip2','xz','lz4','zstd','file',
        'readline','m4','bc','flex','tcl','expect','dejagnu','binutils','gmp',
        'mpfr','mpc','attr','acl','libcap','libxcrypt','shadow','gcc','ncurses',
        'sed','psmisc','gettext','bison','grep','bash','libtool','gdbm','gperf',
        'expat','inetutils','less','perl','xml-parser','intltool','autoconf',
        'automake','openssl','kmod','libelf','libffi','Python','flit-core',
        'wheel','setuptools','ninja','meson','coreutils','check','diffutils',
        'gawk','findutils','groff','gzip','iproute2','kbd','libpipeline',
        'make','patch','tar','texinfo','vim','markupsafe','jinja2','udev',
        'man-db','procps-ng','util-linux','e2fsprogs','pkgconf','sysklogd',
        'sysvinit'
    ],
    'ch9-config': ['etcshells','inputrc','locale','network','symlinks','usage'],
    'ch10-boot':  ['fstab','kernel','grub'],
}

# Book commands that are interactive or reshape the shell; neutralize for
# unattended execution. Replacements preserve intent while keeping the
# script non-interactive.
PATCHES = [
    # re-exec bash to pick up new /etc/passwd+/etc/group entries; harmless to skip in a script
    (re.compile(r'^\s*exec\s+/usr/bin/bash\s+--login\s*$', re.MULTILINE),
     '# exec /usr/bin/bash --login   # skipped: automated build'),
    # interactive kernel config; assume a defconfig is provided out-of-band
    (re.compile(r'^\s*make\s+menuconfig\s*$', re.MULTILINE),
     'make defconfig   # book uses `make menuconfig`; automated build uses defconfig'),
    # passwd prompts
    (re.compile(r'^\s*passwd\s+(root|tester)\s*$', re.MULTILINE),
     r'# passwd \1   # set out-of-band in automated build'),
]

def render(subdir, slug):
    cmds_file = SRC/subdir/f'{slug}.cmds'
    if not cmds_file.exists(): return None
    cmds_text = cmds_file.read_text()
    info = m.get(slug)
    header = f'#!/bin/bash\n# {slug} — from {subdir}\n# See source URL at top of command list below.\nset -euxo pipefail\n\n'

    for pat, rep in PATCHES:
        cmds_text = pat.sub(rep, cmds_text)

    if slug in NON_PKG or not info:
        # just execute commands as-is; assume cwd is $LFS/sources or wherever caller wants
        return header + cmds_text + '\n'

    tb = info['tarball']; d = info['dir']
    body = f'cd "$LFS/sources"\nrm -rf "{d}"\ntar -xf "{tb}"\npushd "{d}" >/dev/null\n\n'
    body += cmds_text
    body += '\npopd >/dev/null\n'
    return header + body

for subdir, order in ORDER.items():
    out = DST/subdir; out.mkdir(parents=True, exist_ok=True)
    # Render scripts for every .cmds file in this chapter, so special
    # non-package slugs (creatingdirs, createfiles, chroot, cleanup, ...)
    # are available to higher-level stage drivers.
    src_dir = SRC/subdir
    all_slugs = sorted({p.stem for p in src_dir.glob('*.cmds')} | set(order))
    for slug in all_slugs:
        s = render(subdir, slug)
        if s is None:
            # Acceptable for pages with no commands (e.g. ch8 introduction).
            continue
        p = out/f'{slug}.sh'
        p.write_text(s); os.chmod(p, 0o755)
    # run-all.sh only invokes the curated order (skipping missing ones).
    run_all = ['#!/bin/bash', 'set -euxo pipefail', 'HERE="$(cd "$(dirname "$0")" && pwd)"', '']
    for slug in order:
        if not (out/f'{slug}.sh').exists():
            print('MISSING', subdir, slug); continue
        run_all.append(f'bash "$HERE/{slug}.sh"')
    (out/'run-all.sh').write_text('\n'.join(run_all)+'\n')
    os.chmod(out/'run-all.sh', 0o755)

print('done')
