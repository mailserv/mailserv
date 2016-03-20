#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install php.ini file (this is a stock php.ini-production)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-5.6.ini /etc/php-5.6/
  
  #To enable the php module please create a symbolic link
  mkdir /var/www/conf/modules
  ln -fs /var/www/conf/modules.sample/php-5.6.conf /var/www/conf/modules/php.conf

  # Install our local changes to php.ini
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-mailserv.ini /etc/php-5.6/mailserv.ini

  # Install php-fpm.conf (replace fast-cgi)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 
 
  # symlink for mysql 
  ln -fs /etc/php-5.6.sample/mysql.ini /etc/php-5.6/mysql.ini

  # Symlink for mcrypt extension
  ln -sf /etc/php-5.6.sample/mcrypt.ini /etc/php-5.6/mcrypt.ini 

  # PHP OPcache config 
  /usr/bin/install -m 644 /var/mailserv/install/templates/opcache.ini /etc/php-5.6/

  # Make php easier to run from CLI
  ln -s /usr/local/bin/php-5.6 /usr/local/bin/php

  #PHP Data Objects (PDO) for accessing databases in PHP (required by roundcube >0.9)
  ln -fs /etc/php-5.6.sample/pdo_mysql.ini  /etc/php-5.6/pdo_mysql.ini

fi
