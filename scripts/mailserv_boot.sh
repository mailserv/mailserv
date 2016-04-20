#/bin/sh

echo -n "starting mailserv daemons:"

# ensure correct file permissions are set
/usr/local/sbin/postfix set-permissions >/dev/null 2>&1
chgrp _dovecot /usr/local/libexec/dovecot/deliver
chmod 4750 /usr/local/libexec/dovecot/deliver
/usr/bin/newaliases

# Collect mail statistics
if [ -f /usr/local/awstats/awstats.pl ]; then
  echo -n ' awstats'
  perl /usr/local/awstats/awstats.pl -config=`hostname` -update > /dev/null &
fi

# Start God system monitoring
if [ -x /usr/local/bin/god ]; then
  echo -n ' god'
  /usr/local/bin/god -c /etc/god/god.conf
fi

echo "."