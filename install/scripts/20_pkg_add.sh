#!/bin/sh

case $1 in

  (upgrade):
    echo "  Upgrading Packages"
    #
    # Upgrade all existing packages
    #
    PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/pub/OpenBSD/`uname -r`/packages/`uname -m`/
    export PKG_PATH
    /usr/sbin/pkg_add -v -u -F update -F updatedepends
    ;;

esac
