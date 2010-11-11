#!/bin/sh

case $1 in

  (install):
    #
    # ClamAV file & permission changes
    #
    touch /var/log/clamd.log && chown _clamav:_clamav /var/log/clamd.log
    touch /var/log/clam-update.log && chown _clamav:_clamav /var/log/clam-update.log
    touch /var/log/freshclam.log && chown _clamav:_clamav /var/log/freshclam.log
    ;;

  (upgrade):
    echo "  Ensuring correct permissions"
    for file in \
        /var/log/imap \
        /var/mailserver/config/permit_relays.pf \
        /var/mailserver/config/spam-rdr.pf; do

      [ ! -f $file ] && touch $file
    done
    ;;

esac

#
# Making dovecot-lda deliver setuid root
# (needed for delivery to different userids)
#
chgrp _dovecot /usr/local/libexec/dovecot/deliver
chmod 4750 /usr/local/libexec/dovecot/deliver

chown -R www:www /var/mailserv/webmail/temp
chmod 700 /root
