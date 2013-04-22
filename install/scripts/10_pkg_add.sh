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
 - php and php-mysql version. Use php-5.3.x and php-mysql-5.3.x and php-pdo-5.3.x


Fetching versions:

__EOT
    pkg_add -v -m -i postfix--mysql 
   
    pkg_add -v -m clamav \
     p5-Mail-SpamAssassin \
     ruby-rails \
     ruby-rrd \
     ruby-mysql \
     ruby-mongrel \
     ruby-fastercsv \
     ruby-highline \
     dovecot-mysql \
     dovecot-pigeonhole \
     mysql-server \
     sqlgrey \
     nginx-- \
     god \
     gtar--      
  
    pkg_add -v -m -i php \
     php-mysql \
     php-pdo_mysql \ 
     php-fpm \
     pecl-APC
     ;;

esac
