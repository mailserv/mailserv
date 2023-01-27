#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m -I nginx

# info
# /usr/local/share/doc/pkg-readmes/nginx


template="/var/mailserv/install/templates"
install -m 644 ${template}/nginx.conf /etc/nginx

rcctl enable nginx
#No chroot
rcctl set nginx flags -u
rcctl start  nginx
