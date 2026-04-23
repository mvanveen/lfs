#!/bin/bash
# cleanup — from ch8-system
# See source URL at top of command list below.
set -euxo pipefail

# source: https://www.linuxfromscratch.org/lfs/view/stable/chapter08/cleanup.html

rm -rf /tmp/{*,.*}

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester


