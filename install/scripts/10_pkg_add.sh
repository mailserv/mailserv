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
     postfix-3.8.20220816p0-mysql \
     clamav \
     gnupg \
     p5-Mail-SPF \
     p5-Mail-SpamAssassin \
     ruby-2.7.7 \
#     dnsmasq \
     dovecot-pigeonhole \
     dovecot-mysql \
     memcached-- \
     mariadb-server \
     nginx \
     openssl \
     sqlgrey \
     gsed \
     gtar--static \
     ghostscript-fonts \
     ghostscript--no_x11 \
     ImageMagick \
#     pecl-memcache \
     lynx \
     vim--no_x11 \
     sudo--
     ;;

esac
