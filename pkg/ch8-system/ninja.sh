#!/bin/bash
# ninja — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "ninja-1.13.1"
tar -xf "ninja-1.13.1.tar.gz"
pushd "ninja-1.13.1" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/ninja.html

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap --verbose

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja


popd >/dev/null
