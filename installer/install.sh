#!/bin/bash
# ==============================================================================
#  mvv linux 12.4 Installer
#  ------------------
#  Designed to run from the live ISO's initramfs.  Pretty TUI in pure bash,
#  no external dialog/whiptail dependency.
#
#  Driven entirely by the squashfs payload at /live/filesystem.squashfs and
#  the kernel + /usr/local tools provided by the initramfs.
# ==============================================================================
set -eo pipefail

# --- env ---------------------------------------------------------------------
LIVE_SQUASH=${LIVE_SQUASH:-/live/filesystem.squashfs}
TARGET=${TARGET:-/mnt/target}
KVER=${KVER:-6.16.1-lfs-12.4}
DRY_RUN=${DRY_RUN:-0}            # 1 = describe actions, never touch disk
LANG=C.UTF-8

# --- pretty primitives -------------------------------------------------------
# 24-bit colour escapes (true colour); fallback to 256-color if TERM lacks it.
csi() { printf '\033[%sm' "$1"; }
fg()  { csi "38;2;$1;$2;$3"; }
bg()  { csi "48;2;$1;$2;$3"; }
rst() { csi 0; }
bold(){ csi 1; }
dim() { csi 2; }
ital(){ csi 3; }
und() { csi 4; }
clr() { printf '\033[2J\033[H'; }    # clear + home
hide_cursor()  { printf '\033[?25l'; }
show_cursor()  { printf '\033[?25h'; }
cursor_to()    { printf '\033[%d;%dH' "$1" "$2"; }
trap 'show_cursor; rst; echo' EXIT INT TERM

# Brand palette (LFS rainbow gradient, indigo->cyan):
COL_A=(80 0 200)     # indigo
COL_B=(33 110 255)   # azure
COL_C=(0 200 230)    # cyan
COL_D=(0 240 180)    # mint
COL_E=(255 200 100)  # amber (warning)
COL_F=(255 80 80)    # red (danger)
COL_W=(240 240 245)  # foreground white-ish
COL_M=(140 140 160)  # muted

# Box-drawing
ROUND_TL='╭'; ROUND_TR='╮'; ROUND_BL='╰'; ROUND_BR='╯'
H='─'; V='│'; CROSS='┼'; T_DOWN='┬'; T_UP='┴'

term_cols() { tput cols 2>/dev/null || echo 80; }
term_rows() { tput lines 2>/dev/null || echo 24; }

# Print a horizontal gradient line of $1 chars.
gradient_line() {
    local n=$1 i=0 r g b
    while [ $i -lt $n ]; do
        # Lerp COL_A -> COL_C across the line.
        local t=$(( i * 1000 / n ))      # 0..1000
        r=$(( COL_A[0] + (COL_C[0]-COL_A[0])*t/1000 ))
        g=$(( COL_A[1] + (COL_C[1]-COL_A[1])*t/1000 ))
        b=$(( COL_A[2] + (COL_C[2]-COL_A[2])*t/1000 ))
        fg "$r" "$g" "$b"
        printf '%s' "$H"
        i=$((i+1))
    done
    rst
}

# Centered text on a $1-wide field, padded with spaces.
center() {
    local w=$1; shift
    local s="$*"
    local n=${#s}
    [ $n -ge $w ] && { printf '%s' "$s"; return; }
    local pad=$(( (w - n) / 2 ))
    printf '%*s%s%*s' "$pad" '' "$s" "$(( w - n - pad ))" ''
}

banner() {
    local cols
    cols=$(term_cols)
    local w=$((cols-4))

    clr
    printf '\n  '
    gradient_line "$w"
    printf '\n'

    fg "${COL_W[@]}"; bold
    printf '  '
    center "$w" '                    ___               '
    printf '\n  '
    center "$w" '  __ _ _  ___  __  / (_)__  __ ____ __ '
    printf '\n  '
    center "$w" ' /  '\'' \ |/ / |/ / / / / _ \/ // /\ \ /'
    printf '\n  '
    center "$w" '/_/_/_/___/|___/ /_/_/_//_/\_,_//_\_\ '
    rst
    printf '\n  '
    gradient_line "$w"
    printf '\n\n'
    fg "${COL_M[@]}"
    center "$cols" "mvv linux 12.4 │ kernel ${KVER} │ glibc 2.42 │ gcc 15.2"
    rst
    printf '\n\n'
}

# CURRENT_BOX_COL holds the current box border colour as 'r g b'.
CURRENT_BOX_COL="${COL_C[*]}"

# Box: rounded corner, optional title, prints the inside through the
# function $4 (which gets the inside width).
# Args: title, pad_h, col_var_name (string, e.g. 'COL_B'), inner_fn
box() {
    local title="$1" pad_h="$2" col_name="$3" inner_fn="$4"
    local cols width inner_w
    cols=$(term_cols)
    width=$(( cols - 2*pad_h ))
    inner_w=$(( width - 4 ))

    # Resolve color array by name -> 'r g b'
    local -n _col="$col_name"
    local r=${_col[0]} g=${_col[1]} b=${_col[2]}
    CURRENT_BOX_COL="$r $g $b"

    fg "$r" "$g" "$b"
    printf '%*s%s' "$pad_h" '' "$ROUND_TL"
    if [ -n "$title" ]; then
        printf '%s ' "$H$H"
        bold; printf '%s' "$title"; rst; fg "$r" "$g" "$b"
        printf ' '
        local used=$(( ${#title} + 4 ))
        local rest=$(( width - used - 1 ))
        local i=0; while [ $i -lt "$rest" ]; do printf '%s' "$H"; i=$((i+1)); done
    else
        local i=0; while [ $i -lt $((width-1)) ]; do printf '%s' "$H"; i=$((i+1)); done
    fi
    printf '%s\n' "$ROUND_TR"
    rst

    "$inner_fn" "$pad_h" "$inner_w"

    fg "$r" "$g" "$b"
    printf '%*s%s' "$pad_h" '' "$ROUND_BL"
    local i=0; while [ $i -lt $((width-1)) ]; do printf '%s' "$H"; i=$((i+1)); done
    printf '%s\n' "$ROUND_BR"
    rst
}

# Helper for box content -- pads each line to inner_w and bookends with V.
# Visual width != ${#s} when string contains ANSI escapes; we strip them
# for length math.
strip_ansi() {
    # POSIX-y: pipe through sed.
    printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*[A-Za-z]//g'
}
boxline() {
    local pad_h=$1 inner_w=$2; shift 2
    local content="$*"
    local plain visible padding
    plain=$(strip_ansi "$content")
    visible=${#plain}
    padding=$(( inner_w - visible ))
    [ $padding -lt 0 ] && padding=0
    # shellcheck disable=SC2086
    fg $CURRENT_BOX_COL
    printf '%*s%s' "$pad_h" '' "$V"
    rst
    printf ' %s%*s ' "$content" "$padding" ''
    # shellcheck disable=SC2086
    fg $CURRENT_BOX_COL
    printf '%s\n' "$V"
    rst
}

# Spinner that runs while $@ is in progress.
spin_pid=
start_spinner() {
    local msg="$*"
    hide_cursor
    (
        local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
        local i=0
        while :; do
            fg "${COL_C[@]}"
            printf '\r  %s ' "${frames[i]}"
            fg "${COL_W[@]}"
            printf '%s' "$msg"
            rst
            i=$(( (i+1) % 10 ))
            sleep 0.08
        done
    ) &
    spin_pid=$!
}
stop_spinner() {
    if [ -n "$spin_pid" ] && kill -0 "$spin_pid" 2>/dev/null; then
        kill "$spin_pid" 2>/dev/null
        wait "$spin_pid" 2>/dev/null || true
    fi
    spin_pid=
    printf '\r\033[K'
    show_cursor
}

# Gradient progress bar.  $1 = fraction 0..100, $2 = label.
progress() {
    local frac=$1 label="$2"
    local cols width filled empty
    cols=$(term_cols)
    width=$((cols - 14))
    filled=$(( frac * width / 100 ))
    empty=$(( width - filled ))

    printf '\r  '
    fg "${COL_M[@]}"; printf '%-12s' "$label"; rst
    printf '['
    local i=0
    while [ $i -lt $filled ]; do
        local t=$(( i * 1000 / width ))
        local r=$(( COL_B[0] + (COL_D[0]-COL_B[0])*t/1000 ))
        local g=$(( COL_B[1] + (COL_D[1]-COL_B[1])*t/1000 ))
        local b=$(( COL_B[2] + (COL_D[2]-COL_B[2])*t/1000 ))
        fg "$r" "$g" "$b"
        printf '█'
        i=$((i+1))
    done
    fg "${COL_M[@]}"
    while [ $empty -gt 0 ]; do printf '░'; empty=$((empty-1)); done
    rst
    printf ']  '
    bold; printf '%3d%%' "$frac"; rst
}

ok()    { fg "${COL_D[@]}"; printf '  ✓ '; rst; printf '%s\n' "$*"; }
warn()  { fg "${COL_E[@]}"; printf '  ⚠ '; rst; printf '%s\n' "$*"; }
err()   { fg "${COL_F[@]}"; printf '  ✗ '; rst; printf '%s\n' "$*"; }
info()  { fg "${COL_C[@]}"; printf '  → '; rst; printf '%s\n' "$*"; }

# --- step: welcome -----------------------------------------------------------
step_welcome() {
    banner
    body() {
        local p=$1 w=$2
        boxline "$p" "$w" ""
        boxline "$p" "$w" "$(fg "${COL_W[@]}"; printf 'Welcome.'; rst)"
        boxline "$p" "$w" ""
        boxline "$p" "$w" "This installer will lay mvv linux 12.4 onto a disk of your choice."
        boxline "$p" "$w" ""
        boxline "$p" "$w" "$(fg "${COL_E[@]}"; printf '⚠ '; rst)Everything on the chosen disk will be erased."
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Press $(bold; printf '[Enter]'; rst) to begin, or $(bold; printf 'Ctrl-C'; rst) to abort."
        boxline "$p" "$w" ""
    }
    box "What this is" 4 COL_C body
    printf '\n'
    read -r _
}

# --- step: pick disk ---------------------------------------------------------
list_disks() {
    # name, size, model -- sorted by name.  Skip loop / ram / sr* by default.
    if [ "$DRY_RUN" = 1 ]; then
        cat <<EOF
sda   32G   QEMU HARDDISK
sdb   16G   QEMU HARDDISK
nvme0n1   500G   Samsung SSD 970 EVO Plus
EOF
        return
    fi
    lsblk -dno NAME,SIZE,MODEL 2>/dev/null \
        | awk '$1 !~ /^(loop|ram|sr|fd)/ && $2 != "" { printf "%-12s  %-6s  ", $1, $2; for (i=3;i<=NF;i++) printf "%s ", $i; print "" }'
}

step_pick_disk() {
    banner
    declare -gA disks
    # Pre-compute disk list so the body() inside box() can read it via globals.
    local i=1
    DISK_LINES=()
    while IFS= read -r line; do
        DISK_LINES+=("$line")
        disks[$i]=$(echo "$line" | awk '{print $1}')
        i=$((i+1))
    done < <(list_disks)

    body() {
        local p=$1 w=$2
        boxline "$p" "$w" "$(fg "${COL_W[@]}"; printf 'Detected disks:'; rst)"
        boxline "$p" "$w" ""
        local n=1
        for line in "${DISK_LINES[@]}"; do
            boxline "$p" "$w" "$(fg "${COL_D[@]}"; printf ' [%d] ' "$n"; rst; fg "${COL_W[@]}"; printf '%s' "$line"; rst)"
            n=$((n+1))
        done
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Type the number of the disk to install LFS onto."
        boxline "$p" "$w" ""
    }
    box "Choose target disk" 4 COL_B body
    printf '\n  '
    fg "${COL_C[@]}"; printf '> '; rst
    read -r choice
    TARGET_DISK=${disks[$choice]:-}
    if [ -z "$TARGET_DISK" ]; then
        err "Invalid choice."
        exit 1
    fi
    info "You picked: /dev/$TARGET_DISK"
}

# --- step: confirm -----------------------------------------------------------
step_confirm() {
    printf '\n'
    body() {
        local p=$1 w=$2
        boxline "$p" "$w" ""
        boxline "$p" "$w" "$(fg "${COL_F[@]}"; bold; printf 'DANGER ZONE'; rst)"
        boxline "$p" "$w" ""
        boxline "$p" "$w" "About to wipe and partition: $(bold; printf '/dev/%s' "$TARGET_DISK"; rst)"
        boxline "$p" "$w" "Layout:"
        boxline "$p" "$w" "    /dev/${TARGET_DISK}1     512M    ext4   /boot"
        boxline "$p" "$w" "    /dev/${TARGET_DISK}2     2G      swap   <swap>"
        boxline "$p" "$w" "    /dev/${TARGET_DISK}3     rest    ext4   /"
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Type $(bold; printf 'YES'; rst) to proceed, anything else to abort."
        boxline "$p" "$w" ""
    }
    box "Confirm wipe" 4 COL_F body
    printf '\n  '
    fg "${COL_F[@]}"; printf '> '; rst
    read -r ans
    [ "$ans" = "YES" ] || { warn "Aborted by user."; exit 1; }
}

# --- step: partition ---------------------------------------------------------
maybe() {
    if [ "$DRY_RUN" = 1 ]; then
        printf '  '; dim; printf '$ %s\n' "$*"; rst
    else
        eval "$@"
    fi
}

step_partition() {
    printf '\n'
    info "Partitioning /dev/$TARGET_DISK …"
    start_spinner "wiping partition table"
    maybe "wipefs -a /dev/$TARGET_DISK >/dev/null"
    sleep 0.6
    stop_spinner
    ok "wiped"

    start_spinner "creating GPT layout"
    maybe "parted -s /dev/$TARGET_DISK mklabel gpt \\
        mkpart primary ext4 1MiB 513MiB \\
        mkpart primary linux-swap 513MiB 2561MiB \\
        mkpart primary ext4 2561MiB 100% \\
        set 1 boot on"
    sleep 0.6
    stop_spinner
    ok "GPT created"

    start_spinner "mkfs.ext4 /boot"
    maybe "mkfs.ext4 -F -L LFSBOOT /dev/${TARGET_DISK}1 >/dev/null"
    stop_spinner; ok "ext4 on /dev/${TARGET_DISK}1"

    start_spinner "mkswap"
    maybe "mkswap -L LFSSWAP /dev/${TARGET_DISK}2 >/dev/null"
    stop_spinner; ok "swap on /dev/${TARGET_DISK}2"

    start_spinner "mkfs.ext4 /"
    maybe "mkfs.ext4 -F -L LFSROOT /dev/${TARGET_DISK}3 >/dev/null"
    stop_spinner; ok "ext4 on /dev/${TARGET_DISK}3"
}

# --- step: extract rootfs ----------------------------------------------------
step_extract() {
    printf '\n'
    info "Mounting target & extracting rootfs"
    maybe "mkdir -p $TARGET"
    maybe "mount /dev/${TARGET_DISK}3 $TARGET"
    maybe "mkdir -p $TARGET/boot"
    maybe "mount /dev/${TARGET_DISK}1 $TARGET/boot"
    maybe "swapon /dev/${TARGET_DISK}2"

    if [ "$DRY_RUN" = 1 ]; then
        # animated fake progress
        local i=0
        while [ $i -le 100 ]; do
            progress "$i" "rootfs"
            sleep 0.02
            i=$((i+2))
        done
        printf '\n'
    else
        local total filled
        total=$(stat -c%s "$LIVE_SQUASH")
        # Use unsquashfs and tail -f progress; for now do a simple pipe.
        unsquashfs -f -d "$TARGET" "$LIVE_SQUASH" \
            | awk -v total="$total" 'BEGIN{s=0} { s+=length($0)+1; printf "\r%d", s*100/total; fflush() }' \
            | while read -r p; do progress "$p" "rootfs"; done
        printf '\n'
    fi
    ok "rootfs extracted"
}

# --- step: grub install ------------------------------------------------------
step_grub() {
    printf '\n'
    info "Installing GRUB onto /dev/${TARGET_DISK}"
    start_spinner "grub-install"
    maybe "for d in dev proc sys run; do mount --rbind /\$d $TARGET/\$d; done"
    maybe "chroot $TARGET grub-install --target=i386-pc /dev/${TARGET_DISK}"
    maybe "chroot $TARGET sh -c 'cat > /boot/grub/grub.cfg <<EOF
set default=0
set timeout=5
menuentry \"mvv linux 12.4\" {
    linux /vmlinuz-${KVER} root=/dev/${TARGET_DISK}3 ro
}
EOF'"
    sleep 0.5
    stop_spinner
    ok "GRUB installed; menu written"
}

# --- step: done --------------------------------------------------------------
step_done() {
    printf '\n'
    body() {
        local p=$1 w=$2
        boxline "$p" "$w" ""
        boxline "$p" "$w" "$(fg "${COL_D[@]}"; bold; printf '✓ Installation complete'; rst)"
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Eject the install medium and reboot to enter your new system."
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Username:  $(bold; printf 'root'; rst)        Password:  $(bold; printf '<unset>'; rst)"
        boxline "$p" "$w" ""
        boxline "$p" "$w" "Press $(bold; printf '[Enter]'; rst) to reboot."
        boxline "$p" "$w" ""
    }
    box "Done" 4 COL_D body
    read -r _ || true
    [ "$DRY_RUN" = 1 ] || maybe "reboot -f"
}

# --- main --------------------------------------------------------------------
main() {
    step_welcome
    step_pick_disk
    step_confirm
    step_partition
    step_extract
    step_grub
    step_done
}

main "$@"
