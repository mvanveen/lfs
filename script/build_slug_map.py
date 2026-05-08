"""Infer tarball filename and extracted dir per slug."""
import os, re, json, pathlib

pkgs = open('packages.txt').read().split()
tarballs = [os.path.basename(u) for u in pkgs if not u.endswith('.patch')]
patches  = [os.path.basename(u) for u in pkgs if u.endswith('.patch')]

def strip_ext(name):
    for ext in ('.tar.xz','.tar.gz','.tar.bz2','.tgz','.tar','.zip'):
        if name.endswith(ext):
            return name[:-len(ext)]
    return name

# normalize for matching: case-insensitive, hyphens, drop version
def base_pkg_name(tname):
    n = strip_ext(tname)
    # remove trailing -src
    n = re.sub(r'-src$','',n)
    # strip trailing version
    m = re.match(r'^(.+?)-(\d[\w.+-]*)$', n)
    if m: return m.group(1), m.group(2), n
    return n, '', n

slugs = set()
for d in pathlib.Path('script/book-html').glob('*/*.cmds'):
    slugs.add(d.stem)

mapping = {}
for t in tarballs:
    name, ver, extracted = base_pkg_name(t)
    for s in slugs:
        # many aliases
        candidates = {s.lower(), s.lower().replace('-pass1','').replace('-pass2','').replace('-pass','')}
        if s == 'iproute2': candidates.add('iproute')
        if s == 'man-db':   candidates.add('man-db')
        if s == 'man-pages':candidates.add('man-pages')
        if s == 'procps-ng':candidates.add('procps-ng')
        if s == 'pkgconf':  candidates.add('pkgconf')
        if s == 'xml-parser': candidates.add('xml-parser')
        if s == 'sysvinit': candidates.add('sysvinit')
        if s == 'gcc-libstdc++': candidates.add('gcc')  # uses gcc tarball
        if s.startswith('gcc'): candidates.add('gcc')
        if s.startswith('binutils'): candidates.add('binutils')
        if s == 'Python' or s == 'python': candidates.add('python')
        if s == 'tcl': candidates.add('tcl8.6.16')
        if name.lower() in candidates:
            mapping[s] = {'tarball': t, 'dir': extracted}
            break

# Overrides for tricky cases
manual = {
    'tcl':       {'tarball':'tcl8.6.16-src.tar.gz','dir':'tcl8.6.16'},
    'Python':    {'tarball':'Python-3.13.7.tar.xz','dir':'Python-3.13.7'},
    'python':    {'tarball':'Python-3.13.7.tar.xz','dir':'Python-3.13.7'},
    'jinja2':    {'tarball':'jinja2-3.1.6.tar.gz','dir':'jinja2-3.1.6'},
    'markupsafe':{'tarball':'markupsafe-3.0.2.tar.gz','dir':'markupsafe-3.0.2'},
    'flit-core': {'tarball':'flit_core-3.12.0.tar.gz','dir':'flit_core-3.12.0'},
    'wheel':     {'tarball':'wheel-0.46.1.tar.gz','dir':'wheel-0.46.1'},
    'setuptools':{'tarball':'setuptools-80.9.0.tar.gz','dir':'setuptools-80.9.0'},
    'packaging': {'tarball':'packaging-25.0.tar.gz','dir':'packaging-25.0'},
    'xml-parser':{'tarball':'XML-Parser-2.47.tar.gz','dir':'XML-Parser-2.47'},
    'vim':       {'tarball':'vim-9.1.1629.tar.gz','dir':'vim-9.1.1629'},
    'bc':        {'tarball':'bc-7.0.3.tar.xz','dir':'bc-7.0.3'},
    'iproute2':  {'tarball':'iproute2-6.16.0.tar.xz','dir':'iproute2-6.16.0'},
    'udev':      {'tarball':'systemd-257.8.tar.gz','dir':'systemd-257.8'},
    'iana-etc':  {'tarball':'iana-etc-20250807.tar.gz','dir':'iana-etc-20250807'},
    'lfs-bootscripts':{'tarball':'lfs-bootscripts-20250827.tar.xz','dir':'lfs-bootscripts-20250827'},
    'ninja':     {'tarball':'ninja-1.13.1.tar.gz','dir':'ninja-1.13.1'},
    'meson':     {'tarball':'meson-1.8.3.tar.gz','dir':'meson-1.8.3'},
    'systemd-man-pages':{'tarball':'systemd-man-pages-257.8.tar.xz','dir':'systemd-man-pages-257.8'},
    'zlib':      {'tarball':'zlib-1.3.1.tar.gz','dir':'zlib-1.3.1'},
    'libxcrypt': {'tarball':'libxcrypt-4.4.38.tar.xz','dir':'libxcrypt-4.4.38'},
    'lz4':       {'tarball':'lz4-1.10.0.tar.gz','dir':'lz4-1.10.0'},
    'ninja':     {'tarball':'ninja-1.13.1.tar.gz','dir':'ninja-1.13.1'},
    'pkgconf':   {'tarball':'pkgconf-2.5.1.tar.xz','dir':'pkgconf-2.5.1'},
    'tzdata':    {'tarball':'tzdata2025b.tar.gz','dir':'tzdata2025b'},
    'udev-lfs':  {'tarball':'udev-lfs-20230818.tar.xz','dir':'udev-lfs-20230818'},
}
mapping.update(manual)

json.dump(mapping, open('script/slug_map.json','w'), indent=2, sort_keys=True)
# report unmatched slugs from cmds files
for s in sorted(slugs):
    if s not in mapping and s not in ('introduction','chroot','changingowner','kernfs','createfiles','creatingdirs','cleanup','aboutdebug','stripping','pkgmgt','abouttestsuites','etcshells','inputrc','locale','network','symlinks','usage','fstab','dejagnu','expect'):
        print('UNMATCHED:', s)
