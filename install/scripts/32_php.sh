#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

## PHP
pkg_add -v -m -I \
    php-8.0.27 \
    php-intl-8.0.27 \
    php-mysqli-8.0.27 \
    php-pdo_mysql-8.0.27 \
    php-gd-8.0.27 \

# info
# /usr/local/share/doc/pkg-readmes/php-8.0

# Create symlinks for all installed php extensions
cd /etc/php-8.0.sample
for i in *; do ln -sf ../php-8.0.sample/$i ../php-8.0/; done

# Install our local changes to php.ini
/usr/bin/install -m 644 /var/mailserv/install/templates/php-mailserv.ini /etc/php-8.0/mailserv.ini

# Install php-fpm.conf
/usr/bin/install -m 644 /var/mailserv/install/templates/php-fpm.conf /etc/ 

# Make php easier to run from CLI
ln -s /usr/local/bin/php-8.0 /usr/local/bin/php

rcctl enable php80_fpm
rcctl start  php80_fpm


## PHPMYADMIN
pkg_add -v -m -I phpMyAdmin

# info
# /usr/local/share/doc/pkg-readmes/phpMyAdmin

sed -i '/cfg/s/cookie/config/g' /var/www/phpMyAdmin/config.inc.php
sed -i '/cfg/s/localhost/127.0.0.1/g' /var/www/phpMyAdmin/config.inc.php
sed -i '/AllowNoPassword/s/false/true/g' /var/www/phpMyAdmin/config.inc.php

