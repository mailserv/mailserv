#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

/var/mailserv/scripts/install_awstats
