#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install php.ini file
  /usr/bin/install -m 644 /var/mailserv/install/templates/php.ini /var/www/conf

fi
