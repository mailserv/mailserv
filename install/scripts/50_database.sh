#!/bin/sh

if [[ "$1" == "install" ]]; then
    /usr/local/bin/mysql_install_db > /dev/null
fi

/usr/local/bin/mysqld_start

case $1 in

  (install):
    echo -n "  creating databases"
    unset VERSION
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/mail.sql
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/spamcontrol.sql
    /usr/local/bin/mysql < /var/mailserv/install/templates/sql/webmail.sql
    cd /var/mailserv/admin && /usr/local/bin/rake db:migrate RAILS_ENV=production > /dev/null 2>&1

    /usr/local/bin/ruby /var/mailserv/scripts/rrdmon_create.rb
    echo "."
    ;;

  (upgrade):
    echo -n "  Updating database schema"
    # Update the database
    if [[ ! -d /install/system/ ]]; then
      cd /var/mailserv/admin && /usr/local/bin/rake RAILS_ENV=production db:migrate > /dev/null
    fi
    # Delete the cached javascript and stylesheet caches
    rm -f /var/sfta/app/public/javascripts/all.js /var/sfta/app/public/stylesheets/all.css 2>/dev/null
    echo "."
    ;;

esac

