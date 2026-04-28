#!/bin/bash
# Inside chroot: build chapters 7 (final parts), 8, 9, 10.
set -euo pipefail

STAMP_DIR=/sources/.done/build
LOG_DIR=/sources/.log/build

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

cd /sources/build

run_pkg /sources/build/creatingdirs.sh
run_pkg /sources/build/createfiles.sh
run_pkg /sources/build/gettext.sh
run_pkg /sources/build/bison.sh
run_pkg /sources/build/perl.sh
run_pkg /sources/build/Python.sh
run_pkg /sources/build/texinfo.sh
run_pkg /sources/build/util-linux.sh
run_pkg /sources/build/cleanup.sh
run_pkg /sources/build/man-pages.sh
run_pkg /sources/build/iana-etc.sh
run_pkg /sources/build/glibc.sh
run_pkg /sources/build/zlib.sh
run_pkg /sources/build/bzip2.sh
run_pkg /sources/build/xz.sh
run_pkg /sources/build/lz4.sh
run_pkg /sources/build/zstd.sh
run_pkg /sources/build/file.sh
run_pkg /sources/build/readline.sh
run_pkg /sources/build/m4.sh
run_pkg /sources/build/bc.sh
run_pkg /sources/build/flex.sh
run_pkg /sources/build/tcl.sh
run_pkg /sources/build/expect.sh
run_pkg /sources/build/dejagnu.sh
run_pkg /sources/build/pkgconf.sh
run_pkg /sources/build/binutils.sh
run_pkg /sources/build/gmp.sh
run_pkg /sources/build/mpfr.sh
run_pkg /sources/build/mpc.sh
run_pkg /sources/build/attr.sh
run_pkg /sources/build/acl.sh
run_pkg /sources/build/libcap.sh
run_pkg /sources/build/libxcrypt.sh
run_pkg /sources/build/shadow.sh
run_pkg /sources/build/gcc.sh
run_pkg /sources/build/ncurses.sh
run_pkg /sources/build/sed.sh
run_pkg /sources/build/psmisc.sh
run_pkg /sources/build/gettext-final.sh
run_pkg /sources/build/bison-final.sh
run_pkg /sources/build/grep.sh
run_pkg /sources/build/bash.sh
run_pkg /sources/build/libtool.sh
run_pkg /sources/build/gdbm.sh
run_pkg /sources/build/gperf.sh
run_pkg /sources/build/expat.sh
run_pkg /sources/build/inetutils.sh
run_pkg /sources/build/less.sh
run_pkg /sources/build/perl-final.sh
run_pkg /sources/build/xml-parser.sh
run_pkg /sources/build/intltool.sh
run_pkg /sources/build/autoconf.sh
run_pkg /sources/build/automake.sh
run_pkg /sources/build/openssl.sh
run_pkg /sources/build/libelf.sh
run_pkg /sources/build/libffi.sh
run_pkg /sources/build/Python-final.sh
run_pkg /sources/build/flit-core.sh
run_pkg /sources/build/packaging.sh
run_pkg /sources/build/wheel.sh
run_pkg /sources/build/setuptools.sh
run_pkg /sources/build/ninja.sh
run_pkg /sources/build/meson.sh
run_pkg /sources/build/kmod.sh
run_pkg /sources/build/coreutils.sh
run_pkg /sources/build/diffutils.sh
run_pkg /sources/build/gawk.sh
run_pkg /sources/build/findutils.sh
run_pkg /sources/build/groff.sh
run_pkg /sources/build/grub.sh
run_pkg /sources/build/gzip.sh
run_pkg /sources/build/iproute2.sh
run_pkg /sources/build/kbd.sh
run_pkg /sources/build/libpipeline.sh
run_pkg /sources/build/make.sh
run_pkg /sources/build/patch.sh
run_pkg /sources/build/tar.sh
run_pkg /sources/build/texinfo-final.sh
run_pkg /sources/build/vim.sh
run_pkg /sources/build/markupsafe.sh
run_pkg /sources/build/jinja2.sh
run_pkg /sources/build/udev.sh
run_pkg /sources/build/man-db.sh
run_pkg /sources/build/procps-ng.sh
run_pkg /sources/build/util-linux-final.sh
run_pkg /sources/build/e2fsprogs.sh
run_pkg /sources/build/sysklogd.sh
run_pkg /sources/build/sysvinit.sh
run_pkg /sources/build/etcshells.sh
run_pkg /sources/build/inputrc.sh
run_pkg /sources/build/locale.sh
run_pkg /sources/build/network.sh
run_pkg /sources/build/symlinks.sh
run_pkg /sources/build/usage.sh
run_pkg /sources/build/fstab.sh
run_pkg /sources/build/kernel.sh
run_pkg /sources/build/grub-final.sh
