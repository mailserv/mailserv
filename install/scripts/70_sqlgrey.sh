#!/bin/sh

if [[ "$1" == "install" ]]; then

  /usr/local/bin/mysqld_start
  install -m 644 /var/mailserv/install/templates/sqlgrey.conf /etc/sqlgrey/
  /usr/local/bin/mysqladmin create sqlgrey
  /usr/local/bin/mysql -e "grant all privileges on sqlgrey.* to 'sqlgrey'@'localhost' identified by 'sqlgrey';"
  /usr/local/sbin/sqlgrey -d
  sleep 2
  /usr/local/bin/mysql sqlgrey -e "alter table connect add id int primary key auto_increment first;"
  /usr/local/bin/mysqladmin shutdown

fi
