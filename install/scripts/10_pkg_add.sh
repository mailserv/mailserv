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
    

Fetching versions:

__EOT
    pkg_add -v -m -I \
     postfix-3.0.2-mysql \
     clamav \
     gnupg-2.1.4 \
     p5-Mail-SPF \
     p5-Mail-SpamAssassin \
     rrdtool \
     ruby-gems-1.8.24 \
     ruby-rake-0.9.2.2p0 \
     ruby-iconv \
     dnsmasq \
     dovecot-pigeonhole \
     dovecot-mysql \
     memcached-1.4.24 \
     mariadb-server \
     nginx-1.9.3p3 \
     openssl-1.0.1pp1 \
     sqlgrey \
     gsed \
     gtar-1.28p1-static \
     php-5.6.11 \
     php-fpm-5.6.11p0 \
     php-mysqli-5.6.11 \
     php-pdo_mysql-5.6.11 \
     php-gd-5.6.11 \
     php-mcrypt-5.6.11 \
     ghostscript-fonts \
     ghostscript--no_x11 \
     ImageMagick \
     pecl-memcache \
     lynx \
     vim-7.4.769-no_x11 \
     sudo-1.8.14.3
     ;;

esac
