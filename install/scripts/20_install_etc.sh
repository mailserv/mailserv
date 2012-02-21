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

install -m 644 ${template}/dovecot.conf /etc/dovecot

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
# Symlinks for ruby stuff v4.9 
# --------------------------------------------------------------

hi_ver_check=`uname -r | awk '{ if ($1 >= 4.9) print "true"; else print "false" }'`


#version check
if [[ $hi_ver_check == "true"  ]]; then
     ln -sf /usr/local/bin/python2.6 /usr/local/bin/python
     ln -sf /usr/local/bin/python2.6-config /usr/local/bin/python-config
     ln -sf /usr/local/bin/pydoc2.6  /usr/local/bin/pydoc
     ln -sf /usr/local/bin/ruby18 /usr/local/bin/ruby
     ln -sf /usr/local/bin/erb18 /usr/local/bin/erb
     ln -sf /usr/local/bin/irb18 /usr/local/bin/irb
     ln -sf /usr/local/bin/rdoc18 /usr/local/bin/rdoc
     ln -sf /usr/local/bin/ri18 /usr/local/bin/ri
     ln -sf /usr/local/bin/testrb18 /usr/local/bin/testrb

     ln -sf /usr/local/bin/gem18 /usr/local/bin/gem
     ln -sf /usr/local/bin/rake18 /usr/local/bin/rake

     # -----------------------------------------------------
     # Update your RAILS_GEM_VERSION
     # -----------------------------------------------------
     echo "Updating rails:"
    /usr/local/bin/gem install -V -v=2.3.4 rails; 
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
