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



# info
# https://obsd.solutions/en/blog/2022/03/04/openbsd-acme-client-70-for-letsencrypt-certificates/
# /etc/examples/acme-client.conf

cp -p /etc/examples/acme-client.conf /etc/
#sed -i 's/me@example.com/info@`hostname`/' /etc/acme-client.conf
#sed -i -e '/^domain example.com {$/,$d' /etc/acme-client.conf
sed -i -e '/^authority buypass {$/,$d' /etc/acme-client.conf
cat <<EOF >> /etc/acme-client.conf
domain `hostname` {    
    domain key "/etc/ssl/private/server.key"
    domain full chain certificate "/etc/ssl/server.crt"
    sign with letsencrypt    
    challengedir /var/www/webmail/webmail
}
EOF

acme-client -v `hostname`

#TEST diff /etc/examples/acme-client.conf /etc/acme-client.conf
