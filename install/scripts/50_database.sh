#!/bin/sh

if [[ "$1" == "install" ]]; then
  /usr/local/bin/mysql_install_db > /dev/null 2>&1
  rcctl enable mysqld
  rcctl set mysqld flags --pid-file=mysql.pid
  rcctl start  mysqld
fi

/usr/local/bin/mysqladmin ping >/dev/null 2>&1
while [ $? -ne 0 ]; do
  sleep 1; /usr/local/bin/mysqladmin ping >/dev/null 2>&1
done
# We now know that the database is running

case $1 in

  (install):
    echo -n "  creating databases"
    unset VERSION
    /usr/local/bin/mysql -e "grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';"
    /usr/local/bin/mysql -e "grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';"

    cd /var/mailserv/admin && /usr/local/bin/rake -s db:setup RAILS_ENV=production
    cd /var/mailserv/admin && /usr/local/bin/rake -s db:migrate RAILS_ENV=production
    /usr/local/bin/mysql mail < /var/mailserv/install/templates/sql/mail.sql
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql

    echo "."
    ;;

  (upgrade):
    echo -n "  Updating database schema"
    # Update the database
    cd /var/mailserv/admin && /usr/local/bin/rake RAILS_ENV=production db:migrate
    # Delete the cached javascript and stylesheet caches
    rm -f /var/sfta/app/public/javascripts/all.js /var/sfta/app/public/stylesheets/all.css 2>/dev/null
    echo "."
    ;;

esac
