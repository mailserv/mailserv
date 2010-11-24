#!/bin/sh

case $1 in

  (install):
    mkdir -p /var/www/webmail
    echo "<?php header( 'Location: webmail/' ); ?>" > /var/www/webmail/index.php
    ;;

esac
