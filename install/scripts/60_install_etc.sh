#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

template="/var/mailserv/install/templates"
install -m 644 \
  ${template}/clamd.conf \
  ${template}/daily.local \
  ${template}/monthly.local \
  ${template}/dovecot-sql.conf \
  ${template}/freshclam.conf \
  ${template}/login.conf \
  ${template}/my.cnf \
  ${template}/newsyslog.conf \
  ${template}/profile \
  ${template}/rc.conf.local \
  ${template}/rc.shutdown \
  ${template}/rrdmon.conf \
  ${template}/syslog.conf \
  ${template}/clamav-milter.conf \
  /etc

install -m 600 ${template}/pf.conf /etc
install -m 644 ${template}/nginx.conf /etc/nginx

install -m 644 /usr/local/share/mailserv/template/dovecot.conf /etc
install -m 644 /var/mailserv/install/templates/spamassassin_local.cf /etc/mail/spamassassin/local.cf
install -m 644 /var/mailserv/install/templates/rc.local /etc

# --------------------------------------------------------------
# /etc/motd
# --------------------------------------------------------------
echo ""  > /etc/motd
echo "" >> /etc/motd
echo "Welcome to Mailserv" >> /etc/motd
date >> /etc/motd
echo "" >> /etc/motd

# --------------------------------------------------------------
# /etc/rc.local
# --------------------------------------------------------------

/usr/local/bin/ruby -pi -e '
  $_.gsub!("[ -f /etc/rc.local ] && . /etc/rc.local", "")
  $_.gsub!(/^date/, "[ -f /etc/rc.local ] && . /etc/rc.local")
  ' /etc/rc

# --------------------------------------------------------------
# /etc/services
# --------------------------------------------------------------
cat <<EOF >> /etc/services
smtps             465/tcp             # SMTPs
managesieve       2000/tcp            # Sieve Remote Management
mailadm           4200/tcp            # Mailserver admin port
EOF

# --------------------------------------------------------------
# /etc/daily
# --------------------------------------------------------------
/usr/local/bin/ruby -pi -e '$_.gsub!(/\/var\/spool\/mqueue/, "Mail queue")' /etc/daily

# --------------------------------------------------------------
# /etc/awstats
# --------------------------------------------------------------
mkdir /etc/awstats

# --------------------------------------------------------------
# /var/cron/tabs/root
# --------------------------------------------------------------
install -m 600 /install/templates/crontab_root /var/cron/tabs/root

# --------------------------------------------------------------
# /etc/mail/aliases
# --------------------------------------------------------------
cat <<EOF >> /etc/mail/aliases
#
# Email system messages to the mailserver admins
#
root: |/usr/local/share/mailserv/sysmail.rb
EOF
/usr/bin/newaliases >/dev/null 2>&1

# --------------------------------------------------------------
# /etc/sysctl.conf
# --------------------------------------------------------------
/usr/local/bin/rake -s -f /var/mailserv/admin/Rakefile system:update_hostname RAILS_ENV=production

chgrp 0 /etc/daily.local \
        /etc/login.conf \
        /etc/monthly.local \
        /etc/pf.conf \
        /etc/rc.conf.local \
        /etc/rc.local \
        /etc/rc.shutdown \
        /etc/shells /etc/syslog.conf \
        /etc/syslog.conf
