#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

basedir="/var/www/webmail"
mkdir -p $basedir

echo "Getting Roundcube version 1.6.0"
#system "ftp -Vmo - http://sourceforge.net/projects/roundcubemail/files/latest/download | tar zxf - -C #{basedir}"
#force to install 1.6.0
ftp -Vmo - https://github.com/roundcube/roundcubemail/releases/download/1.6.0/roundcubemail-1.6.0-complete.tar.gz | tar zxf - -C $basedir

# Linking 
rm -f ${basedir}/webmail
#Point the webmail symlink at the latest version of roundcube we've got
#symlink must be relative path important for nginx 
ln -s `cd ${basedir}; ls -1 -r -d roundcubemail-*|head -n 1` ${basedir}/webmail

#Redirect for old configs
mkdir -p ${basedir}/webmail/webmail
echo "<?php header('Location: /', true, 301); ?>" > ${basedir}/webmail/webmail/index.php

echo "Downloading plugins"
cd ${basedir}/webmail;
#download and prepare  composer first 
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

#copy composer profile composer.json from template 
install -m 644 /var/mailserv/install/templates/roundcube/conf/composer.json  ${basedir}/webmail/

#install plugins
cd ${basedir}/webmail
php composer.phar install

#make temp writable by the web server user
chown www ${basedir}/webmail/temp

#remove roundcube installer
#Needed for bin/upgrade.sh
#rm -r ${basedir}/webmail/installer

echo "Installing Configuration"
install -m 0644 /var/mailserv/install/templates/roundcube/conf/config.inc.php        #{basedir}/webmail/config/
#install -m 0644 /var/mailserv/install/templates/roundcube/messagesize/config.inc.php #{basedir}/webmail/plugins/messagesize/
install -m 0644 /var/mailserv/install/templates/roundcube/sieverules/config.inc.php  #{basedir}/webmail/plugins/sieverules/
install -m 0644 /var/mailserv/install/templates/roundcube/sauserprefs/config.inc.php #{basedir}/webmail/plugins/sauserprefs/
install -m 0644 /var/mailserv/install/templates/roundcube/password/config.inc.php    #{basedir}/webmail/plugins/password/


/var/mailserv/scripts/install_roundcube

echo "Finished\n\n"
echo "If you have updated, please have a look at #{basedir}/webmail/SQL/mysql"
echo "and apply as needed.\n\n"
echo "Also, please test the plugins (especially sieve/filter, spam and password)."
echo "This is especially true if you have installed a new major release.\n\n"

/usr/local/bin/mysqladmin create webmail
/usr/local/bin/mysql webmail < /var/www/webmail/webmail/SQL/mysql.initial.sql
/usr/local/bin/mysql webmail -e "grant all privileges on webmail.* to 'webmail'@'localhost' identified by 'webmail'"
