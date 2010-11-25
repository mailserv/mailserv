#!/bin/sh

case $1 in

  (install):
    mkdir -p /var/www/webmail
    echo "<?php header( 'Location: webmail/' ); ?>" > /var/www/webmail/index.php
    /var/mailserv/scripts/install_roundcube
    /usr/local/bin/mysqladmin create webmail
    /var/www/webmail/webmail/SQL/mysql.initial.sql
    /usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"
    ;;

esac
