#!/bin/bash
failed()
{
    echo '
********************
*** BUILD FAILED ***
********************
'
    echo "Keeping container alive for debugging..."
    tail -f /dev/null
}

trap 'failed' 0

set -e
set -x

source stage0.sh
source mkext4.sh
source stage1.sh
echo "PRE PARALLEL"
cat packages.txt | parallel "wget --continue --directory-prefix=/mnt/lfs/sources {}"
echo "POST PARALLEL"
cd /mnt/lfs/sources
source binutils.sh
source gcc-pass1.sh
source linux-headers.sh
source glibc.sh
source libstdcplusplus.sh
source binutils-pass-2.sh
source gcc-pass2.sh
source tcl.sh
source expect.sh
source dejagnu.sh
source m4.sh
source ncurses.sh
source bash.sh
source bison.sh
source bzip2.sh
source coreutils.sh
source diffutils.sh
source file.sh
source findutils.sh
source gawk.sh
source gettext.sh
source grep.sh
source make.sh
source patch.sh
source perl.sh
source python.sh
source sed.sh
source tar.sh
source texinfo.sh
source xz.sh

trap : 0

echo '
***********************
*** BUILD SUCCEEDED ***
***********************
'
tail -f /dev/null
