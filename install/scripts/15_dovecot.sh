#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

pkg_add -v -m -I \
    dovecot \
    dovecot-pigeonhole \
    dovecot-mysql


template="/var/mailserv/install/templates"
install -m 644 ${template}/dovecot.conf /etc/dovecot/local.conf
install -m 644 ${template}/dovecot-sql.conf /etc/dovecot
mv /etc/dovecot/conf.d/auth-system.conf.ext /etc/dovecot/conf.d/auth-system.conf.ext.org
cat <<EOF > /etc/dovecot/conf.d/auth-system.conf.ext
passdb {
  args = /etc/dovecot/dovecot-sql.conf
  driver = sql
}
userdb {
  args = /etc/dovecot/dovecot-sql.conf
  driver = sql
}
EOF



#
# Making dovecot-lda deliver setuid root
# (needed for delivery to different userids)
#
touch /var/log/imap
chgrp _dovecot /usr/local/libexec/dovecot/dovecot-lda
chmod 4750 /usr/local/libexec/dovecot/dovecot-lda
mkdir -p /var/mailserv/mail
