#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m -I rrdtool
template="/var/mailserv/install/templates"
install -m 644 ${template}/rrdmon.conf /etc
/usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb
