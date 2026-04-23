#!/bin/bash
# xml-parser — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "XML-Parser-2.47"
tar -xf "XML-Parser-2.47.tar.gz"
pushd "XML-Parser-2.47" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/xml-parser.html

perl Makefile.PL

make

make test

make install


popd >/dev/null
