#!/bin/sh

# Only run on install
[[ "$1" != "install" ]] && exit 1

# --------------------------------------------------------------
# sasl and filesystem stuff
# --------------------------------------------------------------
install /var/mailserv/install/templates/fs/bin/* /usr/local/bin/
install /var/mailserv/install/templates/fs/sbin/* /usr/local/sbin/

mkdir -p /usr/local/share/mailserv
install /var/mailserv/install/templates/fs/mailserv/* /usr/local/share/mailserv

template="/var/mailserv/install/templates"
install -m 644 \
  ${template}/clamd.conf \
  ${template}/daily.local \
  ${template}/monthly.local \
  ${template}/freshclam.conf \
  ${template}/login.conf \
  ${template}/my.cnf \
  ${template}/newsyslog.conf \
  ${template}/profile \
  ${template}/rc.shutdown \
  ${template}/rrdmon.conf \
  ${template}/syslog.conf \
  ${template}/clamav-milter.conf \
  /etc

install -m 644 ${template}/dovecot.conf /etc/dovecot
install -m 644 ${template}/dovecot-sql.conf /etc/dovecot

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
# Setup package daemons
# --------------------------------------------------------------
# -s deprecated
# rcctl set ntpd flags -s
rcctl stop sndiod
rcctl disable sndiod

# add pidfile to flags
rcctl set memcached flags `rcctl get memcached flags` --pidfile=/var/run/memcached/memcached.pid
rcctl enable memcached
rcctl start  memcached

rcctl enable dnsmasq
rcctl start  dnsmasq

rcctl enable spamassassin
rcctl set spamassassin flags -u _spamdaemon -P -s mail -xq -r /var/run/spamassassin.pid -i 127.0.0.1
rcctl start  spamassassin

# --------------------------------------------------------------
# /etc/services
# --------------------------------------------------------------

if [ `grep -i managesieve /etc/services | wc -l` -eq 0 ]; then
cat <<EOF >> /etc/services
managesieve 2000/tcp # Sieve Remote Management old port
managesieve 4190/tcp # Sieve Remote Management new port
EOF
fi

if [ `grep mailadm /etc/services | wc -l` -eq 0 ]; then
cat <<EOF >> /etc/services
mailadm 4200/tcp # Mailserver admin port
EOF
fi

if [ `grep smtps /etc/services | wc -l` -eq 0 ]; then
cat <<EOF >> /etc/services
smtps 465/tcp # SMTPs
EOF
fi

# --------------------------------------------------------------
# Symlinks for ruby stuff 
# --------------------------------------------------------------


  #ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
  #ln -sf /usr/local/bin/python2.7-2to3 /usr/local/bin/2to3
  #ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config
  #ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc

  # set default system ruby	 
  ln -sf /usr/local/bin/ruby27 /usr/local/bin/ruby
  ln -sf /usr/local/bin/erb27 /usr/local/bin/erb
  ln -sf /usr/local/bin/irb27 /usr/local/bin/irb
  ln -sf /usr/local/bin/rdoc27 /usr/local/bin/rdoc
  ln -sf /usr/local/bin/ri27 /usr/local/bin/ri
  ln -sf /usr/local/bin/rake27 /usr/local/bin/rake
  ln -sf /usr/local/bin/gem27 /usr/local/bin/gem
  ln -sf /usr/local/bin/bundle27 /usr/local/bin/bundle
  ln -sf /usr/local/bin/bundler27 /usr/local/bin/bundler
  ln -sf /usr/local/bin/racc27 /usr/local/bin/racc
  ln -sf /usr/local/bin/racc2y27 /usr/local/bin/racc2y
  ln -sf /usr/local/bin/y2racc27 /usr/local/bin/y2racc

  # -----------------------------------------------------
  # Update your RAILS_GEM_VERSION
  # -----------------------------------------------------
  echo " Installing rails:"
  /usr/local/bin/gem install -V -v=2.3.4 rails
  echo " Installing rubby apps:"
  /usr/local/bin/gem install -V -v=1.6.21 highline
  /usr/local/bin/gem install -V god rdoc fastercsv ruby-mysql #mongrel

  #ln -sf /usr/local/bin/mongrel_rails18 /usr/local/bin/mongrel_rails
  ln -sf /usr/local/bin/rails27 /usr/local/bin/rails 
  ln -sf /usr/local/bin/god27 /usr/local/bin/god


# --------------------------------------------------------------
# /etc/awstats
# --------------------------------------------------------------
mkdir /etc/awstats

# --------------------------------------------------------------
# /var/cron/tabs/root
# --------------------------------------------------------------
cat /var/mailserv/install/templates/crontab_root >> /var/cron/tabs/root
rcctl restart cron


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
#/usr/local/bin/rake -s -f /var/mailserv/admin/Rakefile system:update_hostname RAILS_ENV=production

chgrp 0 /etc/daily.local \
        /etc/login.conf \
        /etc/monthly.local \
        /etc/pf.conf \
        /etc/rc.local \
        /etc/rc.shutdown \
        /etc/shells /etc/syslog.conf \
        /etc/syslog.conf

# --------------------------------------------------------------
# /etc/god
# --------------------------------------------------------------
mkdir /etc/god
install -m 644 /var/mailserv/install/templates/fs/god/* /etc/god


