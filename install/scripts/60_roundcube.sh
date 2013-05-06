#!/bin/sh

if [[ "$1" == "install" ]]; then

  /var/mailserv/scripts/install_roundcube
  /usr/local/bin/mysqladmin create webmail
  /usr/local/bin/mysql webmail < /var/www/webmail/webmail/SQL/mysql.initial.sql
  /usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"

  #RC doesn't include a favicon, so use the one from admin
  cp /var/mailserv/admin/public/favicon.ico /var/www/webmail/webmail/

  /var/mailserv/scripts/install_awstats

fi
