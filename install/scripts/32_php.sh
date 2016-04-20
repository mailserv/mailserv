#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install our local changes to php.ini
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-mailserv.ini /etc/php-5.6/mailserv.ini

  # Install php-fpm.conf (replace fast-cgi)
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 
 
  # Make php easier to run from CLI
  ln -s /usr/local/bin/php-5.6 /usr/local/bin/php

  # symlink for mysqli
  ln -sf /etc/php-5.6.sample/mysqli.ini /etc/php-5.6/mysqli.ini

  # Symlink for mcrypt extension
  ln -sf /etc/php-5.6.sample/mcrypt.ini /etc/php-5.6/mcrypt.ini 

  # Symlink for opcache
  ln -sf /etc/php-5.6.sample/opcache.ini /etc/php-5.6/opcache.ini

  #PHP Data Objects (PDO) for accessing databases in PHP (required by roundcube >0.9)
  ln -sf /etc/php-5.6.sample/pdo_mysql.ini /etc/php-5.6/pdo_mysql.ini

  # Symlink for gd
  ln -sf /etc/php-5.6.sample/gd.ini /etc/php-5.6/gd.ini
  
  # Symlink for memcache
  ln -sf /etc/php-5.6.sample/memcache.ini /etc/php-5.6/memcache.ini
  
  rcctl enable php_fpm
  rcctl start  php_fpm
fi
