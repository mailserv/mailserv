#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m -I \
    dovecot \
    dovecot-pigeonhole \
    dovecot-mysql

template="/var/mailserv/install/templates"
install -m 644 ${template}/dovecot.conf /etc/dovecot
install -m 644 ${template}/dovecot-sql.conf /etc/dovecot


#
# Making dovecot-lda deliver setuid root
# (needed for delivery to different userids)
#
touch /var/log/imap
chgrp _dovecot /usr/local/libexec/dovecot/dovecot-lda
chmod 4750 /usr/local/libexec/dovecot/dovecot-lda  
mkdir /var/mailserv/mail >/dev/null 2>&1
