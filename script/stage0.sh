rm -f /bin/sh
ln -s /bin/bash /bin/sh

addgroup lfs
useradd -s /bin/bash -g lfs -k /dev/null -m lfs
#su - lfs

su lfs -c "cat > ~/.bash_profile << "EOF"
exec env -i HOME=\$HOME TERM=\$TERM PS1='\u:\w\$ ' /bin/bash
EOF"

su lfs -c "cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=\$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF"

mkdir -p ~lfs/.ssh
chmod 0700 ~/.ssh
sed -i -e 's/^lfs:!:/lfs::/' /etc/shadow
su lfs -c "ssh-keygen -A"

