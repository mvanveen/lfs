#!/bin/bash
# Drive pkg/prep/*.sh in book order (runs as the lfs user).
set -euo pipefail

STAMP_DIR=/mnt/lfs/sources/.done/prep
LOG_DIR=/mnt/lfs/sources/.log/prep

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


run_pkg /mnt/lfs/sources/prep/binutils-pass1.sh
run_pkg /mnt/lfs/sources/prep/gcc-pass1.sh
run_pkg /mnt/lfs/sources/prep/linux-headers.sh
run_pkg /mnt/lfs/sources/prep/glibc.sh
run_pkg /mnt/lfs/sources/prep/gcc-libstdc++.sh
run_pkg /mnt/lfs/sources/prep/m4.sh
run_pkg /mnt/lfs/sources/prep/ncurses.sh
run_pkg /mnt/lfs/sources/prep/bash.sh
run_pkg /mnt/lfs/sources/prep/coreutils.sh
run_pkg /mnt/lfs/sources/prep/diffutils.sh
run_pkg /mnt/lfs/sources/prep/file.sh
run_pkg /mnt/lfs/sources/prep/findutils.sh
run_pkg /mnt/lfs/sources/prep/gawk.sh
run_pkg /mnt/lfs/sources/prep/grep.sh
run_pkg /mnt/lfs/sources/prep/gzip.sh
run_pkg /mnt/lfs/sources/prep/make.sh
run_pkg /mnt/lfs/sources/prep/patch.sh
run_pkg /mnt/lfs/sources/prep/sed.sh
run_pkg /mnt/lfs/sources/prep/tar.sh
run_pkg /mnt/lfs/sources/prep/xz.sh
run_pkg /mnt/lfs/sources/prep/binutils-pass2.sh
run_pkg /mnt/lfs/sources/prep/gcc-pass2.sh
