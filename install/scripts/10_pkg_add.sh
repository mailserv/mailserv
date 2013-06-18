#!/bin/sh

if [ X"$PKG_PATH" == X"" ]; then
  export PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/
  grep PKG_PATH /etc/profile || echo "export PKG_PATH=http://ftp.OpenBSD.org/pub/OpenBSD/`uname -r`/packages/`uname -m`/" >> /etc/profile
fi

case $1 in

  (install):
    echo "Installing packages"
    mkdir /var/db/spamassassin 2>/dev/null
    cat <<__EOT
    
You will be prompted to install:
 - postfix version. The recommendation is to install the first version 

Fetching versions:

__EOT
    pkg_add -v -m -i postfix--mysql 
  
    pkg_add -v -m -I \
     clamav \
     gnupg-1.4.13 \
     p5-Mail-SPF \
     p5-Mail-SpamAssassin \
     dovecot-pigeonhole \
     memcached \
     mysql-server \
     nginx-1.2.3p1 \
     sqlgrey \
     gsed \
     gtar-- \
     php-5.3.21 \
     php-mysqli-5.3.21 \
     php-pdo_mysql-5.3.21 \
     php-gd-5.3.21 \
     php-mcrypt-5.3.21 \
     ghostscript-fonts \
     ghostscript--no_x11 \
     ImageMagick \
     php-fpm \
     pecl-APC \
     pecl-memcache
     ;;

esac
