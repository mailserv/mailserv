#!/bin/sh

case $1 in

  (install):
    #
    # ClamAV file & permission changes
    #
    touch /var/log/clamd.log && chown _clamav:_clamav /var/log/clamd.log
    touch /var/log/clam-update.log && chown _clamav:_clamav /var/log/clam-update.log
    touch /var/log/freshclam.log && chown _clamav:_clamav /var/log/freshclam.log

    useradd -g =uid -u 901 -s /bin/ksh -d /var/mailserv _mailserv
    echo "_mailserv   ALL=(ALL) NOPASSWD: SETENV: ALL" >> /etc/sudoers
    cd /var/mailserv/admin && chown -R _mailserv:_mailserv log db public
    cd /var/mailserv/admin/public && chown _mailserv:_mailserv javascripts stylesheets
    ;;

esac

#
# Making dovecot-lda deliver setuid root
# (needed for delivery to different userids)
#
chgrp _dovecot /usr/local/libexec/dovecot/deliver
chmod 4750 /usr/local/libexec/dovecot/deliver
