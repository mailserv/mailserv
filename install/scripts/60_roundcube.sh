#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

/var/mailserv/scripts/install_roundcube
/usr/local/bin/mysqladmin create webmail
/usr/local/bin/mysql webmail < /var/www/webmail/webmail/SQL/mysql.initial.sql
/usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"
