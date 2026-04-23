#!/bin/bash
# Stage 0: host setup for LFS 12.4.
#   - create the unprivileged `lfs` user
#   - prepare $LFS/{sources,tools} and symlinks per ch 2 & 4
# See:
#   https://www.linuxfromscratch.org/lfs/view/stable/chapter04/addinguser.html
#   https://www.linuxfromscratch.org/lfs/view/stable/chapter04/settingenvironment.html
set -euxo pipefail

export LFS=${LFS:-/mnt/lfs}

# /bin/sh must be bash on the host.
ln -sfv bash /bin/sh

# $LFS/sources (world-writable, sticky) and $LFS/tools (cross toolchain).
mkdir -pv "$LFS/sources" "$LFS/tools"
chmod -v a+wt "$LFS/sources"

# Convenience symlink so /tools inside chroot points to $LFS/tools.
ln -svf "$LFS/tools" /

# Create the lfs user.
if ! id lfs >/dev/null 2>&1; then
  groupadd lfs || true
  useradd -s /bin/bash -g lfs -m -k /dev/null lfs
  # Passwordless (SSH-only).
  sed -i -e 's/^lfs:!:/lfs::/' /etc/shadow
fi
chown -v lfs "$LFS" "$LFS/sources" "$LFS/tools"

# Give the lfs user our SSH keys.
install -d -m 700 -o lfs -g lfs /home/lfs/.ssh
cp /root/.ssh/authorized_keys /home/lfs/.ssh/authorized_keys
chown lfs:lfs /home/lfs/.ssh/authorized_keys
chmod 600 /home/lfs/.ssh/authorized_keys

# lfs user login environment (§4.4).
cat > /home/lfs/.bash_profile << 'EOF'
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > /home/lfs/.bashrc << EOF
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$LFS/tools/bin:\$PATH
CONFIG_SITE=\$LFS/usr/share/config.site
MAKEFLAGS="-j\$(nproc)"
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF
chown lfs:lfs /home/lfs/.bash_profile /home/lfs/.bashrc
