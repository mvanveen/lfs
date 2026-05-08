# Upstream issue draft: shells/bash parallel-make race

**Target:** NetBSD pkgsrc (file via send-pr / pkgsrc-bugs@ / GitHub mirror
[NetBSD/pkgsrc](https://github.com/NetBSD/pkgsrc))

**Suggested title:** `shells/bash: build fails with MAKE_JOBS>=2 (rm hash.c races regenerator)`

**Component:** shells/bash

**Severity:** non-critical, blocks unattended builds with default parallel make

---

## Body

### Description

`pkgsrc-2025Q3/shells/bash` (bash 5.3 / 5.3.3) fails to build when
`MAKE_JOBS>=2` due to a parallel-make race in upstream bash's
`builtins/Makefile.in`:

```
cc1: fatal error: hash.c: No such file or directory
compilation terminated.
make[1]: *** [Makefile:104: hash.o] Error 1
*** [./builtins/libbuiltins.a] Error code 1
bmake: stopped making "all loadables" in /var/tmp/pkgsrc-build/shells/bash/work/bash-5.3
```

### Root cause

bash 5.3's builtins recipe both `rm -f hash.c` (right before regenerating
it via `mkbuiltins`) and compiles `hash.c` to `hash.o`, without an
explicit dependency edge between the two recipes. With `-j>=2`, make can
schedule:

```
worker A: rm -f hash.c             # about to regenerate
worker B: cc -c hash.c             # reads it after the rm, before
                                   # mkbuiltins finishes -> ENOENT
```

This affects multiple generated `.c` files in `builtins/`
(`hash.c`, `fc.c`, others).

### Reproduction (pkgsrc tree, x86_64-linux-gnu)

```sh
cd $PKGSRC/shells/bash
bmake clean
MAKE_JOBS=2 bmake install
```

Single-job (`MAKE_JOBS=1` or `MAKE_JOBS_SAFE=no`) succeeds.

### Suggested fix

Add `MAKE_JOBS_SAFE= no` to `pkgsrc/shells/bash/Makefile` until upstream
patches the race. Long-term: send a patch upstream to make the `.c <-`
generator dependency explicit and drop the `rm -f`.

### Workaround we are using

In our LFS+pkgsrc distribution we set in `mk.conf`:

```make
.if !empty(PKGPATH:Mshells/bash)
MAKE_JOBS_SAFE=          no
.endif
```

### Cross-references

- Our tracking ticket: Fossil ticket `9dc35fb08c` at
  https://waltz-tare.exe.xyz/tktview/9dc35fb08c
- pkgsrc version: `pkgsrc-2025Q3` checked out from
  `https://github.com/NetBSD/pkgsrc.git`
- Toolchain: gcc 15.2.0, glibc 2.42, on Linux From Scratch 12.4
  (sysv) booted with kernel 6.16.1.

### Environment

- `uname -srm`: `Linux 6.16.1 x86_64`
- `bmake -V MAKE_VERSION` (pkgsrc bmake): 20240901
- `gcc --version`: 15.2.0
- `MAKE_JOBS`: 2 (default in our `mk.conf`)
