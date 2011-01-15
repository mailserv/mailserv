#!/bin/sh

if [[ "$1" == "install" ]]; then

  /usr/local/bin/mysqld_start
  mkdir -p /var/www/webmail
  echo "<?php header( 'Location: webmail/' ); ?>" > /var/www/webmail/index.php
  /var/mailserv/scripts/install_roundcube
  /usr/local/bin/mysqladmin create webmail
  /usr/local/bin/mysql webmail < /var/www/webmail/webmail/SQL/mysql.initial.sql
  /usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"

  /var/mailserv/scripts/install_awstats
  /usr/local/bin/mysqladmin shutdown

fi
