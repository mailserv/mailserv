#!/bin/sh

case $1 in

  (install):
    useradd -g =uid -u 901 -s /bin/ksh -d /var/mailserv _mailserv
    echo "_mailserv   ALL=(ALL) NOPASSWD: SETENV: ALL" >> /etc/sudoers
    cd /var/mailserv/admin && chown -R _mailserv:_mailserv log db public tmp
    cd /var/mailserv/admin/public && chown _mailserv:_mailserv javascripts stylesheets

    cd /var/mailserv/account && chown -R _mailserv:_mailserv log public tmp
    cd /var/mailserv/account/public && chown _mailserv:_mailserv javascripts stylesheets
    ;;

esac

#
# Making dovecot-lda deliver setuid root
# (needed for delivery to different userids)
#
touch /var/log/imap
chgrp _dovecot /usr/local/libexec/dovecot/deliver
chmod 4750 /usr/local/libexec/dovecot/deliver
mkdir /var/mailserv/mail >/dev/null 2>&1
