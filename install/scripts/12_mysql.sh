#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1
   
pkg_add -v -m -I mariadb-server

# info:
# /usr/local/share/doc/pkg-readmes/mariadb-server
# /usr/local/share/examples/mysql
# /etc/login.conf.d/mysqld

# initialize MariaDB data directory
/usr/local/bin/mysql_install_db

#use default my.cnf
#template="/var/mailserv/install/templates"
#install -m 644 ${template}/my.cnf

rcctl enable mysqld
rcctl set mysqld flags --pid-file=mysql.pid
rcctl start  mysqld
