#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

# --------------------------------------------------------------
# /etc/awstats
# --------------------------------------------------------------
mkdir /etc/awstats

/var/mailserv/scripts/install_awstats
