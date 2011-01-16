#!/bin/sh

if [ X"$PKG_PATH" == X"" ]; then
  PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/
  export PKG_PATH
fi

case $1 in

  (install):
    echo "Installing packages"
    mkdir /var/db/spamassassin 2>/dev/null
    cat <<__EOT
    
You will be prompted to install a postfix version. The recommendation is to install
the first version.

Fetching versions:

__EOT
    pkg_add -i postfix--mysql
    pkg_add -v -m clamav \
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
     ;;

esac
