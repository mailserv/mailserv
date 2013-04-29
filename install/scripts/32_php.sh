#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install php.ini file (this is a stock php.ini-production)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-5.3.ini /etc/

  # Install our local changes to php.ini
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-mailserv.ini /etc/php-5.3/mailserv.ini

  # Install php-fpm.conf (replace fast-cgi)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 
 
  # symlink for mysql 
  ln -fs /etc/php-5.3.sample/mysql.ini /etc/php-5.3/mysql.ini

  # PHP APC config
  /usr/bin/install -m 644 /var/mailserv/install/templates/apc.ini /etc/php-5.3/

  # Make php easier to run from CLI
  ln -s /usr/local/bin/php-5.3 /usr/local/bin/php

  #PHP Data Objects (PDO) for accessing databases in PHP (required by roundcube >0.9)
  ln -fs /etc/php-5.3.sample/pdo_mysql.ini  /etc/php-5.3/pdo_mysql.ini

fi
