#!/bin/sh

case $1 in

  (install):
    echo "Installing packages"
    mkdir /var/db/spamassassin
    groupadd -g 200 _postdrop
    groupadd -g 201 _postfix
    useradd -u 201 -g 201 -s /sbin/nologin -d /nonexistent \
      -c "Disgruntled Postal Worker" _postfix
    pkg_add clamav \
     p5-Mail-SpamAssassin \
     ruby-rails \
     ruby-rrd \
     ruby-mysql \
     ruby-mongrel \
     ruby-fastercsv \
     ruby-highline \
     cyrus-sasl--mysql \
     dovecot--mysql \
     dovecot-sieve \
     mysql-server \
     sqlgrey \
     php5-core \
     php5-mysql \
     php5-fastcgi \
     nginx-- \
     god \
     gtar--

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
