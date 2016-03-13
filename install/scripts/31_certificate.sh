#!/bin/sh

if [ ! -f /etc/ssl/private/server.key ]; then
  # Generate SSL keys if none exists

  echo -n 'openssl: Generating new SSL certificate.'
  /usr/bin/openssl genrsa -out /etc/ssl/private/server.key 2048 2>/dev/null
  echo -n '.'
  /usr/bin/openssl req -new -key /etc/ssl/private/server.key \
    -out /tmp/server.csr -subj "/CN=`hostname`" 2>/dev/null
  echo -n '.'
  /usr/bin/openssl x509 -req -days 1095 -in /tmp/server.csr \
    -signkey /etc/ssl/private/server.key -out /etc/ssl/server.crt 2>/dev/null
  rm -f /tmp/server.csr
  echo '. done.'
fi
