#!/bin/sh

rm /usr/local/bin/mailserver
install -m 755 /var/mailserv/install/templates/fs/bin/mailserv /usr/local/bin/

pkg_delete postfix
pkg_add postfix-mysql
install -m 644 /var/mailserv/install/templates/dovecot.conf /etc/

