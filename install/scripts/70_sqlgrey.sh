#!/bin/sh

if [[ "$1" == "install" ]]; then

  install -m 644 /var/mailserv/install/templates/sqlgrey.conf /etc/sqlgrey/
  /usr/local/bin/mysqladmin create sqlgrey
  /usr/local/bin/mysql -e "grant all privileges on sqlgrey.* to 'sqlgrey'@'localhost' identified by 'sqlgrey';"
  rcctl enable sqlgrey
  rcctl start  sqlgrey
  sleep 2
  /usr/local/bin/mysql sqlgrey -e "alter table connect add id int primary key auto_increment first;"
  touch /etc/sqlgrey/clients_fqdn_whitelist.local 
  touch /etc/sqlgrey/clients_ip_whitelist.local 
fi
