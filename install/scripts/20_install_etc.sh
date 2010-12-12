#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

# --------------------------------------------------------------
# sasl and filesystem stuff
# --------------------------------------------------------------
mkdir -p /usr/local/lib/sasl2
install -m 644 /var/mailserv/install/templates/smtpd.conf /usr/local/lib/sasl2

install /var/mailserv/install/templates/fs/bin/* /usr/local/bin/
install /var/mailserv/install/templates/fs/sbin/* /usr/local/sbin/

mkdir -p /usr/local/share/mailserv
install /var/mailserv/install/templates/fs/mailserv/* /usr/local/share/mailserv


template="/var/mailserv/install/templates"
install -m 644 \
  ${template}/clamd.conf \
  ${template}/daily.local \
  ${template}/monthly.local \
  ${template}/dovecot.conf \
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
# /etc/services
# --------------------------------------------------------------
if [ `grep sieve /etc/services | wc -l` -eq 0 ]; then
cat <<EOF >> /etc/services
smtps             465/tcp             # SMTPs
managesieve       2000/tcp            # Sieve Remote Management
mailadm           4200/tcp            # Mailserver admin port
EOF
fi

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
install -m 600 /var/mailserv/install/templates/crontab_root /var/cron/tabs/root

# --------------------------------------------------------------
# /etc/mail/aliases
# --------------------------------------------------------------

# either we're upgrading
/usr/local/bin/ruby -pi -e '$_.gsub!(/\/usr\/local\/share\/mailserver\/sysmail.rb/, "/usr/local/share/mailserv/sysmail.rb")' /etc/mail/aliases

# or do a fresh install
if [[ `grep sysmail.rb /etc/mail/aliases | wc -l` -eq 0 ]]; then
cat <<EOF >> /etc/mail/aliases
#
# Email system messages to the mailserv admins
#
root: |/usr/local/share/mailserv/sysmail.rb
EOF
fi
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

# --------------------------------------------------------------
# /etc/god
# --------------------------------------------------------------
mkdir /etc/god
install -m 644 /var/mailserv/install/templates/fs/god/* /etc/god
