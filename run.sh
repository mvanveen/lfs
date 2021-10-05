#!/usr/bin/env bash
#trap 'failed' 0

set -e
set -x

source /home/lfs/.bashrc

cd /mnt/lfs/sources
source binutils.sh

cd /mnt/lfs/sources
source gcc-pass1.sh

cd /mnt/lfs/sources
source make-linux-api-headers.sh

cd /mnt/lfs/sources
source toybox.sh

cd /mnt/lfs/sources
source glibc.sh

cd /mnt/lfs/sources
su lfs -c "/mnt/lfs/sources/libstdcplusplus-pass1.sh"

cd /mnt/lfs/sources
su lfs -c "source m4.sh"

#source binutils-pass-2.sh
#source gcc-pass2.sh
#source tcl.sh
#source expect.sh
#source dejagnu.sh
#source ncurses.sh
#source bash.sh
#source bison.sh
#source bzip2.sh
#source coreutils.sh
#source diffutils.sh
#source file.sh
#source findutils.sh
#source gawk.sh
#source gettext.sh
#source grep.sh
#source make.sh
#source patch.sh
#source perl.sh
#source python.sh
#source sed.sh
#source tar.sh
#source texinfo.sh
#source xz.sh
