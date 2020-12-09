#!/bin/sh

if [ ! -f /etc/installurl ]; then
  echo "Install URL"
  echo 'https://ftp.openbsd.org/pub/OpenBSD/' > /etc/installurl
fi

case $1 in

  (install):
    echo "Installing packages"
    mkdir /var/db/spamassassin 2>/dev/null
    cat <<__EOT
    

Fetching versions:

__EOT
    pkg_add -v -m -I \
     postfix-3.6.20200627-mysql \
     clamav \
     gnupg-2.2.23p0 \
     p5-Mail-SPF \
     p5-Mail-SpamAssassin \
     rrdtool \
     ruby-2.7.1p1
     dnsmasq \
     dovecot-pigeonhole \
     dovecot-mysql \
     memcached-- \
     mariadb-server \
     nginx \
     openssl \
     sqlgrey \
     gsed \
     gtar--static \
     php-7.4.13 \
	   php-intl-7.4.13 \
     php-mysqli-7.4.13 \
     php-pdo_mysql-7.4.13 \
     php-gd-7.4.13 \
     php-mcrypt-7.4.13 \
     ghostscript-fonts \
     ghostscript--no_x11 \
     ImageMagick \
     pecl-memcache \
     lynx \
     vim--no_x11 \
     sudo--
     ;;

esac
