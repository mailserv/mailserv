#!/bin/sh

# Only run on install
if [[ "$1" == "install" ]]; then

  # Create symlinks for all installed php extensions
  cd /etc/php-5.6.sample
  for i in *; do ln -sf ../php-5.6.sample/$i ../php-5.6/; done

  # Install our local changes to php.ini
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-mailserv.ini /etc/php-5.6/mailserv.ini

  # Install php-fpm.conf
  /usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 

  # Make php easier to run from CLI
  ln -s /usr/local/bin/php-5.6 /usr/local/bin/php

  rcctl enable php56_fpm
  rcctl start  php56_fpm
fi
