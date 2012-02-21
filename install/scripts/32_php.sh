#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Install php.ini file
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-5.2.ini /etc/ 

fi
