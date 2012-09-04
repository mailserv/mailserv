#!/bin/sh
# == Synopsis 
# 
# Manages the mailserver on a command line
# 
# == Usage 
# 
# reconfigures the configuration files and restarts the daemons affected.
# Optional flags 
#   "-i"  installs new files without restarting any services.
# 
# == Author 
# Johan Allard <johan@allard.nu>
# 
# == Copyright 
# Copyright (c) 2008 Allard Consulting.

templates="/usr/local/share/mailserver/template"

# --------------------------------------------------------------
# Copy and edit files
# --------------------------------------------------------------

# Postfix
install -C -m 644 /etc/services /etc/resolv.conf /etc/localtime /var/spool/postfix/etc

# Dovecot.conf
/usr/local/bin/ruby -pi -e '$_.gsub!(/^\s*postmaster_address.*/,  "  postmaster_address = postmaster@#{%x{hostname}.strip}")' /etc/dovecot/dovecot.conf

# AWstats
install -m 755 $templates/awstats_cron-stats /usr/local/awstats/cron-stats
/usr/local/bin/ruby -pi -e '$_.gsub!(/localhost/, %x{hostname}.strip)' /usr/local/awstats/cron-stats

[[ ! -d /etc/awstats ]] && mkdir /etc/awstats
install -m 644 $templates/awstats_awstats.localhost.conf /etc/awstats/awstats.`hostname`.conf
/usr/local/bin/ruby -pi -e '
  $_.gsub!(/^SiteDomain=.*/, "SiteDomain=\"#{%x{hostname}.strip}\"")
  $_.gsub!(/^HostAliases=.*/, "HostAliases=\"#{%x{hostname}.strip}\"")
' /etc/awstats/awstats.`hostname`.conf

echo '<META HTTP-EQUIV="Refresh" CONTENT="0; URL=awstats.html">' > /var/www/admin/public/awstats/awstats.`hostname`.html
/usr/local/awstats/cron-stats > /dev/null 2>&1 &

