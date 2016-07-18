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
     postfix-3.0.3p0-mysql \
     clamav \
     gnupg-2.1.9 \
     p5-Mail-SPF \
     p5-Mail-SpamAssassin \
     rrdtool \
     ruby-gems \
     ruby-rake \
     ruby-iconv \
     dnsmasq \
     dovecot-pigeonhole \
     dovecot-mysql \
     memcached-- \
     mariadb-server \
     nginx-- \
     openssl \
     sqlgrey \
     gsed \
     gtar--static \
     php-5.6.18 \
	 php-intl-5.6.18 \
     php-mysqli-5.6.18 \
     php-pdo_mysql-5.6.18 \
     php-gd-5.6.18 \
     php-mcrypt-5.6.18 \
     ghostscript-fonts \
     ghostscript--no_x11 \
     ImageMagick \
     pecl-memcache \
     lynx \
     vim--no_x11 \
     sudo--
     ;;

esac
