#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install php.ini file
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-5.3.ini /etc/
  
  # Install php-fpm.conf (replace fast-cgi)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 
 
  # symlink for mysql 
  ln -fs /etc/php-5.3.sample/mysql.ini /etc/php-5.3/mysql.ini

  # PHP APC config
  /usr/bin/install -m 644 /var/mailserv/install/templates/apc.ini /etc/php-5.3/
 
  #PHP Data Objects (PDO) for accessing databases in PHP (required by roundcube >0.9)
  ln -fs /etc/php-5.3.sample/pdo_mysql.ini  /etc/php-5.3/pdo_mysql.ini
fi
