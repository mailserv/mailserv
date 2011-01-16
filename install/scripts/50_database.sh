#!/bin/sh

if [[ "$1" == "install" ]]; then
    /usr/local/bin/mysql_install_db > /dev/null 2>&1
fi

/usr/local/bin/mysqld_start

case $1 in

  (install):
    echo -n "  creating databases"
    unset VERSION
    /usr/local/bin/mysqladmin create mail
    
    /usr/local/bin/mysql -e "grant select on mail.* to 'postfix'@'localhost' identified by 'postfix';"
    /usr/local/bin/mysql -e "grant all privileges on mail.* to 'mailadmin'@'localhost' identified by 'mailadmin';"
    
    cd /var/mailserv/admin && /usr/local/bin/rake db:schema:load RAILS_ENV=production > /dev/null 2>&1
    cd /var/mailserv/admin && /usr/local/bin/rake db:migrate RAILS_ENV=production > /dev/null 2>&1
    /usr/local/bin/mysql mail < /var/mailserv/install/templates/sql/mail.sql
    /usr/local/bin/mysql mail -e "ALTER TABLE users AUTO_INCREMENT = 2000;"
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql
    /usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb
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
/usr/local/bin/mysqladmin shutdown
