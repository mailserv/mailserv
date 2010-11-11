#/bin/sh

echo -n "Starting mailserv daemons:"

if [[ -f /var/tmp/run_once.sh ]]; then
  . /var/tmp/run_once.sh
  rm /var/tmp/run_once.sh
fi

# ensure correct file permissions are set
/usr/local/sbin/postfix set-permissions >/dev/null 2>&1
chgrp _dovecot /usr/local/libexec/dovecot/deliver
chmod 4750 /usr/local/libexec/dovecot/deliver
/usr/bin/newaliases

/usr/local/bin/mysqld_start

if [ -x /usr/local/sbin/dovecot ]; then
  echo -n ' dovecot'; /usr/local/sbin/dovecot >/dev/null 2>&1
fi

# Update ClamAV databases
if [ -x /usr/local/bin/freshclam ]; then
  echo -n ' freshclam'
  touch /var/run/freshclam.pid
  chown _clamav:_clamav /var/run/freshclam.pid
  /usr/local/bin/freshclam --daemon
fi

# ClamAV Startup
if [ -x /usr/local/sbin/clamd ]; then
    chown _postfix /var/log/clamd.log
    rm -f /var/tmp/clamd
    touch /var/run/clamd.pid
    chown _postfix:_postfix /var/run/clamd.pid
    echo -n ' clamd'; /usr/local/sbin/clamd > /dev/null 2>&1
fi

if [ -x /usr/local/bin/spamd ]; then
  /usr/local/bin/spamd -s mail -u _spamd -dxq -r /var/run/spamd.pid -i 127.0.0.1
fi

# Collect mail statistics
if [ -f /usr/local/awstats/awstats.pl ]; then
  echo -n ' awstats'
  perl /usr/local/awstats/awstats.pl -config=`hostname` -update > /dev/null &
fi

rm -f /var/www/admin/log/mongrel.pid /var/www/user/account/log/mongrel.pid
/usr/local/bin/mongrel_rails start -d -e production -p 4213 -a 127.0.0.1 -c /var/www/admin
/usr/local/bin/mongrel_rails start -d -e production -p 4214 -a 127.0.0.1 -c /var/www/user/account

if [ -x /usr/local/sbin/nginx ]; then
  echo -n ' nginx'
  /usr/local/sbin/nginx
fi

# Start God system monitoring
if [ -x /usr/local/bin/god ]; then
  echo -n ' god'
  /usr/local/bin/god -c /etc/god/god.conf
fi

/usr/local/share/mailserver/console.rb
