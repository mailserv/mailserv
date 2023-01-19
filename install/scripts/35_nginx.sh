#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

rcctl enable nginx
#No chroot
rcctl set nginx flags -u
rcctl start  nginx
