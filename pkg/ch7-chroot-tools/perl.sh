#!/bin/bash
# perl — from ch7-chroot-tools
# See source URL at top of command list below.
set -euxo pipefail

cd "$LFS/sources"
rm -rf "perl-5.42.0"
tar -xf "perl-5.42.0.tar.xz"
pushd "perl-5.42.0" >/dev/null

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/perl.html

sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.42/core_perl     \
             -D archlib=/usr/lib/perl5/5.42/core_perl     \
             -D sitelib=/usr/lib/perl5/5.42/site_perl     \
             -D sitearch=/usr/lib/perl5/5.42/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.42/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.42/vendor_perl

make

make install


popd >/dev/null
